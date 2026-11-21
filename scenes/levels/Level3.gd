class_name Level3
extends Node2D

const ENDING_SCREEN_PATH: String = "res://scenes/ui/EndingScreen.tscn"
const INITIAL_TIME_UNITS: int = 12
const INITIAL_MIN_WAX: int = 4
const TOTAL_REQUIRED_MEMORIES: int = 3

const HOUSE_ITEM_NAMES: Dictionary = {
	"item_photo": "Fotografía",
	"item_letter": "Carta inconclusa",
	"item_ribbon": "Cinta",
	"item_dried_flower": "Flor seca",
	"item_last_letter": "Última carta"
}

var time_units: int = INITIAL_TIME_UNITS
var reconstructed_count: int = 0
var _crafted_memories: Dictionary = {
	"first_meeting": false,
	"the_promise": false,
	"the_farewell": false
}
var _basement_unlocked: bool = false
var _near_binding_altar: bool = false
var _near_basement_altar: bool = false
var _is_ending_triggered: bool = false
var _notification_tween: Tween = null

@onready var environment_layer: TileMapLayer = $EnvironmentLayer
@onready var binding_altar_area: Area2D = $BindingAltarArea
@onready var binding_altar_prompt: Node2D = $BindingAltarArea/InteractPrompt
@onready var basement_altar_area: Area2D = $BasementAltarArea
@onready var basement_altar_prompt: Node2D = $BasementAltarArea/InteractPrompt

@onready var time_label: Label = $HUD/TopBarPanel/MarginContainer/VBoxContainer/StatsRow/TimeLabel
@onready var wax_label: Label = $HUD/TopBarPanel/MarginContainer/VBoxContainer/StatsRow/WaxLabel
@onready var memories_label: Label = $HUD/TopBarPanel/MarginContainer/VBoxContainer/StatsRow/MemoriesLabel
@onready var items_label: Label = $HUD/TopBarPanel/MarginContainer/VBoxContainer/ItemsLabel

@onready var memory_craft_modal: ColorRect = $HUD/MemoryCraftModal
@onready var craft_status_label: Label = $HUD/MemoryCraftModal/MemoryCraftPanel/MarginContainer/VBoxContainer/CraftStatusLabel
@onready var craft_memory_1_button: Button = $HUD/MemoryCraftModal/MemoryCraftPanel/MarginContainer/VBoxContainer/CraftMemory1Button
@onready var craft_memory_2_button: Button = $HUD/MemoryCraftModal/MemoryCraftPanel/MarginContainer/VBoxContainer/CraftMemory2Button
@onready var craft_memory_3_button: Button = $HUD/MemoryCraftModal/MemoryCraftPanel/MarginContainer/VBoxContainer/CraftMemory3Button
@onready var close_craft_button: Button = $HUD/MemoryCraftModal/MemoryCraftPanel/MarginContainer/VBoxContainer/CloseCraftButton

@onready var notification_panel: PanelContainer = $HUD/NotificationPanel
@onready var notification_label: Label = $HUD/NotificationPanel/MarginContainer/NotificationLabel


func _ready() -> void:
	WorldState.current_level = "res://scenes/levels/Level3.tscn"
	if WorldState.wax_remaining < INITIAL_MIN_WAX:
		WorldState.wax_remaining = INITIAL_MIN_WAX

	if notification_panel != null:
		notification_panel.hide()
		notification_panel.modulate.a = 0.0
	if memory_craft_modal != null:
		memory_craft_modal.hide()

	if binding_altar_area != null:
		binding_altar_area.body_entered.connect(_on_binding_altar_body_changed.bind(true))
		binding_altar_area.body_exited.connect(_on_binding_altar_body_changed.bind(false))

	if basement_altar_area != null:
		basement_altar_area.body_entered.connect(_on_basement_altar_body_changed.bind(true))
		basement_altar_area.body_exited.connect(_on_basement_altar_body_changed.bind(false))

	for child: Node in get_children():
		if child is InspectableObject:
			var inspectable: InspectableObject = child as InspectableObject
			inspectable.object_inspected.connect(_on_house_object_inspected)

	craft_memory_1_button.pressed.connect(_on_craft_memory_pressed.bind("first_meeting"))
	craft_memory_2_button.pressed.connect(_on_craft_memory_pressed.bind("the_promise"))
	craft_memory_3_button.pressed.connect(_on_craft_memory_pressed.bind("the_farewell"))
	close_craft_button.pressed.connect(_close_memory_craft_modal)

	WorldState.wax_fragment_collected.connect(_on_wax_fragment_collected)
	WorldState.clue_registered.connect(_on_clue_registered)
	DialogueManager.dialogue_started.connect(_update_prompts)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	_update_hud()
	_update_prompts()


func _unhandled_input(event: InputEvent) -> void:
	if DialogueManager.is_dialogue_active:
		return

	if memory_craft_modal != null and memory_craft_modal.visible:
		if event.is_action_pressed("ui_cancel"):
			_close_memory_craft_modal()
			get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("interact"):
		if _near_binding_altar:
			_open_memory_craft_modal()
			get_viewport().set_input_as_handled()
		elif _near_basement_altar:
			_interact_basement_altar()
			get_viewport().set_input_as_handled()


func _on_house_object_inspected(_inspected_id: String, used_wax: bool) -> void:
	if used_wax and WorldState.wax_remaining > 0:
		WorldState.wax_remaining -= 1
	_consume_time_unit(1)
	_update_hud()


func _consume_time_unit(amount: int) -> void:
	if _basement_unlocked:
		return

	time_units = maxi(0, time_units - amount)
	_update_hud()

	if time_units == 0 and not _basement_unlocked:
		WorldState.time_management["level3_outcome"] = "degraded"
		WorldState.time_management["level3_time_left"] = 0
		_unlock_basement_door(true)


func _open_memory_craft_modal() -> void:
	_refresh_craft_buttons()
	memory_craft_modal.show()
	_update_prompts()


func _close_memory_craft_modal() -> void:
	memory_craft_modal.hide()
	_update_prompts()


func _refresh_craft_buttons() -> void:
	var has_photo: bool = WorldState.clues_found.has("item_photo")
	var has_letter: bool = WorldState.clues_found.has("item_letter")
	var has_ribbon: bool = WorldState.clues_found.has("item_ribbon")
	var has_flower: bool = WorldState.clues_found.has("item_dried_flower")
	var has_last_letter: bool = WorldState.clues_found.has("item_last_letter")
	var has_wax: bool = WorldState.wax_remaining >= 1

	craft_status_label.text = (
		"Combina los objetos hallados en la casa con 1 de Cera dorada para abrir los 3 sellos del sótano. (Cera disponible: %d)"
		% WorldState.wax_remaining
	)

	if bool(_crafted_memories["first_meeting"]):
		craft_memory_1_button.text = "✓ I. El primer encuentro (Reconstruido)"
		craft_memory_1_button.disabled = true
	else:
		craft_memory_1_button.text = "I. El primer encuentro — Fotografía + Carta inconclusa (1 Cera)"
		craft_memory_1_button.disabled = not (has_photo and has_letter and has_wax)

	if bool(_crafted_memories["the_promise"]):
		craft_memory_2_button.text = "✓ II. La promesa (Reconstruido)"
		craft_memory_2_button.disabled = true
	else:
		craft_memory_2_button.text = "II. La promesa — Cinta de encuadernación + Flor seca (1 Cera)"
		craft_memory_2_button.disabled = not (has_ribbon and has_flower and has_wax)

	if bool(_crafted_memories["the_farewell"]):
		craft_memory_3_button.text = "✓ III. La despedida (Reconstruido)"
		craft_memory_3_button.disabled = true
	else:
		craft_memory_3_button.text = "III. La despedida — Última carta de la habitación (1 Cera)"
		craft_memory_3_button.disabled = not (has_last_letter and has_wax)


func _on_craft_memory_pressed(memory_key: String) -> void:
	if bool(_crafted_memories.get(memory_key, false)) or WorldState.wax_remaining < 1:
		return

	WorldState.wax_remaining -= 1
	_crafted_memories[memory_key] = true
	reconstructed_count += 1
	_consume_time_unit(1)
	_close_memory_craft_modal()
	_update_hud()

	if reconstructed_count >= TOTAL_REQUIRED_MEMORIES and not _basement_unlocked:
		WorldState.time_management["level3_outcome"] = "optimal"
		WorldState.time_management["level3_time_left"] = time_units
		_unlock_basement_door(false)

	match memory_key:
		"first_meeting":
			DialogueManager.start_dialogue("recuerdo_primer_encuentro")
		"the_promise":
			DialogueManager.start_dialogue("recuerdo_la_promesa")
		"the_farewell":
			DialogueManager.start_dialogue("recuerdo_la_despedida")


func _unlock_basement_door(by_time_depletion: bool) -> void:
	_basement_unlocked = true
	if environment_layer != null:
		environment_layer.erase_cell(Vector2i(-1, -5))
		environment_layer.erase_cell(Vector2i(0, -5))

	if by_time_depletion:
		_show_notification(
			"El recuerdo se debilita, pero la última chispa del cuaderno te permite abrir el sótano con lo que lograste reunir."
		)
	else:
		_show_notification(
			"¡Los 3 sellos de cera se han abierto! El acceso norte hacia el sótano está desbloqueado."
		)


func _interact_basement_altar() -> void:
	DialogueManager.start_dialogue("sotano_abuelo_inicio")


func _on_wax_fragment_collected(_total: int) -> void:
	_update_hud()
	_show_notification("Has recogido un Fragmento de Cera dorada (+1 Cera disponible).")


func _on_clue_registered(_clue_id: String, _total_clues: int) -> void:
	_update_hud()


func _on_dialogue_ended() -> void:
	_update_prompts()
	_update_hud()

	if bool(WorldState.state.get("final_decision_made", false)) and not _is_ending_triggered:
		_is_ending_triggered = true
		call_deferred("_go_to_ending_screen")


func _update_hud() -> void:
	if time_label != null:
		time_label.text = "Tiempo del recuerdo: %d" % time_units
	if wax_label != null:
		wax_label.text = "Cera dorada: %d" % WorldState.wax_remaining
	if memories_label != null:
		memories_label.text = "Recuerdos reconstruidos: %d / %d" % [reconstructed_count, TOTAL_REQUIRED_MEMORIES]

	if items_label != null:
		var collected_names: PackedStringArray = PackedStringArray()
		for item_key: Variant in HOUSE_ITEM_NAMES.keys():
			var key_str: String = str(item_key)
			if WorldState.clues_found.has(key_str):
				collected_names.append(str(HOUSE_ITEM_NAMES[key_str]))

		if collected_names.is_empty():
			items_label.text = "Objetos de la casa: Ninguno aún (explora el jardín, la sala, el estudio y la habitación)"
		else:
			items_label.text = "Objetos de la casa: " + ", ".join(collected_names)


func _show_notification(message: String) -> void:
	if notification_panel == null or notification_label == null:
		return

	if _notification_tween != null and _notification_tween.is_valid():
		_notification_tween.kill()

	notification_label.text = message
	notification_panel.modulate.a = 0.0
	notification_panel.show()

	_notification_tween = create_tween()
	_notification_tween.tween_property(notification_panel, "modulate:a", 1.0, 0.4)
	_notification_tween.tween_interval(4.5)
	_notification_tween.tween_property(notification_panel, "modulate:a", 0.0, 0.5)
	_notification_tween.tween_callback(notification_panel.hide)


func _on_binding_altar_body_changed(body: Node2D, is_near: bool) -> void:
	if body is Player:
		_near_binding_altar = is_near
		_update_prompts()


func _on_basement_altar_body_changed(body: Node2D, is_near: bool) -> void:
	if body is Player:
		_near_basement_altar = is_near
		_update_prompts()


func _update_prompts() -> void:
	var can_show: bool = (
		not DialogueManager.is_dialogue_active
		and (memory_craft_modal == null or not memory_craft_modal.visible)
	)
	if binding_altar_prompt != null:
		binding_altar_prompt.visible = can_show and _near_binding_altar
	if basement_altar_prompt != null:
		basement_altar_prompt.visible = can_show and _near_basement_altar


func _go_to_ending_screen() -> void:
	get_tree().change_scene_to_file(ENDING_SCREEN_PATH)
