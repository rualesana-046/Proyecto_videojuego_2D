class_name Level3
extends Node2D

const ENDING_SCREEN_PATH: String = "res://scenes/ui/EndingScreen.tscn"
const INITIAL_TIME_UNITS: int = 12
const INITIAL_MIN_WAX: int = 3
const TOTAL_REQUIRED_MEMORIES: int = 3

const HOUSE_ITEM_NAMES: Dictionary = {
	"item_photo": "Fotografía",
	"item_letter": "Carta inconclusa",
	"item_ribbon": "Cinta",
	"item_dried_flower": "Flor seca",
	"item_last_letter": "Última carta"
}

const HOUSE_ITEM_NAMES_EN: Dictionary = {
	"item_photo": "Photograph",
	"item_letter": "Unfinished letter",
	"item_ribbon": "Ribbon",
	"item_dried_flower": "Dried flower",
	"item_last_letter": "Last letter"
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
@onready var objective_label: Label = $HUD/TopBarPanel/MarginContainer/VBoxContainer/ObjectiveLabel

@onready var memory_craft_modal: ColorRect = $HUD/MemoryCraftModal
@onready var craft_title_label: Label = $HUD/MemoryCraftModal/MemoryCraftPanel/MarginContainer/VBoxContainer/CraftTitleLabel
@onready var craft_status_label: Label = $HUD/MemoryCraftModal/MemoryCraftPanel/MarginContainer/VBoxContainer/CraftStatusLabel
@onready var craft_memory_1_button: Button = $HUD/MemoryCraftModal/MemoryCraftPanel/MarginContainer/VBoxContainer/CraftMemory1Button
@onready var craft_memory_2_button: Button = $HUD/MemoryCraftModal/MemoryCraftPanel/MarginContainer/VBoxContainer/CraftMemory2Button
@onready var craft_memory_3_button: Button = $HUD/MemoryCraftModal/MemoryCraftPanel/MarginContainer/VBoxContainer/CraftMemory3Button
@onready var close_craft_button: Button = $HUD/MemoryCraftModal/MemoryCraftPanel/MarginContainer/VBoxContainer/CloseCraftButton

@onready var notification_panel: PanelContainer = $HUD/NotificationPanel
@onready var notification_label: Label = $HUD/NotificationPanel/MarginContainer/NotificationLabel


func _ready() -> void:
	WorldState.current_level = "res://scenes/levels/Level3.tscn"
	WorldState.wax_remaining = maxi(WorldState.wax_remaining, INITIAL_MIN_WAX)

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
			var is_already_collected: bool = (
				not inspectable.grants_clue_id.is_empty()
				and WorldState.clues_found.has(inspectable.grants_clue_id)
			)
			if is_already_collected:
				inspectable._hide_collected_item()
			elif not inspectable.grants_clue_id.is_empty():
				inspectable.always_show_sparkle = true
				if inspectable.wax_sparkle != null:
					inspectable.wax_sparkle.show()

			var col_shape: CollisionShape2D = inspectable.get_node_or_null("CollisionShape2D")
			if col_shape != null:
				var new_shape: CircleShape2D = CircleShape2D.new()
				new_shape.radius = 28.0
				col_shape.shape = new_shape

	if WorldState.inspected_objects.has("house_item_photo_elena") and not WorldState.clues_found.has("item_photo"):
		WorldState.register_clue("item_photo")

	craft_memory_1_button.pressed.connect(_on_craft_memory_pressed.bind("first_meeting"))
	craft_memory_2_button.pressed.connect(_on_craft_memory_pressed.bind("the_promise"))
	craft_memory_3_button.pressed.connect(_on_craft_memory_pressed.bind("the_farewell"))
	close_craft_button.pressed.connect(_close_memory_craft_modal)

	WorldState.wax_fragment_collected.connect(_on_wax_fragment_collected)
	WorldState.clue_registered.connect(_on_clue_registered)
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	if LocaleManager != null:
		LocaleManager.language_changed.connect(func(_new_lang: String) -> void:
			_update_hud()
			if memory_craft_modal != null and memory_craft_modal.visible:
				_refresh_craft_buttons()
		)

	_update_hud()
	_update_prompts()


func _on_dialogue_started() -> void:
	if notification_panel != null:
		notification_panel.hide()
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


func _on_house_object_inspected(inspected_id: String, _used_wax: bool) -> void:
	if inspected_id == "house_item_photo_elena" or inspected_id == "item_photo":
		WorldState.register_clue("item_photo")
	_consume_time_unit(1)
	_update_hud()
	if memory_craft_modal != null and memory_craft_modal.visible:
		_refresh_craft_buttons()


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
	var is_en: bool = LocaleManager != null and LocaleManager.current_lang == "en"

	if craft_title_label != null:
		craft_title_label.text = (
			LocaleManager.pick(
				"Mesa de Encuadernación — Los 3 Sellos",
				"Binding Table — The 3 Seals"
			) if LocaleManager != null else "Mesa de Encuadernación — Los 3 Sellos"
		)

	if close_craft_button != null:
		close_craft_button.text = (
			LocaleManager.pick("Cerrar mesa", "Close Table")
			if LocaleManager != null else "Cerrar mesa"
		)

	craft_status_label.text = (
		LocaleManager.pick(
			"Combina los objetos hallados en la casa con 1 de Cera dorada para abrir los 3 sellos del sótano. (Cera disponible: %d)",
			"Combine items found in the house with 1 Golden Wax to open the 3 basement seals. (Wax available: %d)"
		) if LocaleManager != null else "Combina los objetos hallados en la casa con 1 de Cera dorada para abrir los 3 sellos del sótano. (Cera disponible: %d)"
	) % WorldState.wax_remaining

	# --- I. El primer encuentro ---
	if bool(_crafted_memories["first_meeting"]):
		craft_memory_1_button.text = (
			LocaleManager.pick(
				"I. El primer encuentro — [Recuerdo reconstruido ✓]",
				"I. The First Meeting — [Memory Reconstructed ✓]"
			) if LocaleManager != null else "I. El primer encuentro — [Recuerdo reconstruido ✓]"
		)
		craft_memory_1_button.disabled = true
	else:
		var missing_1: PackedStringArray = PackedStringArray()
		if not has_photo:
			missing_1.append("Photograph (Hall)" if is_en else "Fotografía (Sala)")
		if not has_letter:
			missing_1.append("Letter (Study)" if is_en else "Carta (Estudio)")
		if not has_wax:
			missing_1.append("1 Golden Wax" if is_en else "1 Cera dorada")

		if missing_1.is_empty():
			craft_memory_1_button.text = (
				LocaleManager.pick(
					"I. El primer encuentro — [Listo para sellar · Consume 1 Cera]",
					"I. The First Meeting — [Ready to Seal · Consumes 1 Wax]"
				) if LocaleManager != null else "I. El primer encuentro — [Listo para sellar · Consume 1 Cera]"
			)
			craft_memory_1_button.disabled = false
		else:
			var prefix_1: String = ""
			if is_en:
				prefix_1 = "Missing: "
			else:
				prefix_1 = "Falta: " if missing_1.size() == 1 else "Faltan: "
			var title_1: String = "I. The First Meeting — " if is_en else "I. El primer encuentro — "
			craft_memory_1_button.text = title_1 + prefix_1 + ", ".join(missing_1)
			craft_memory_1_button.disabled = true

	# --- II. La promesa ---
	if bool(_crafted_memories["the_promise"]):
		craft_memory_2_button.text = (
			LocaleManager.pick(
				"II. La promesa — [Recuerdo reconstruido ✓]",
				"II. The Promise — [Memory Reconstructed ✓]"
			) if LocaleManager != null else "II. La promesa — [Recuerdo reconstruido ✓]"
		)
		craft_memory_2_button.disabled = true
	else:
		var missing_2: PackedStringArray = PackedStringArray()
		if not has_ribbon:
			missing_2.append("Ribbon (Study)" if is_en else "Cinta (Estudio)")
		if not has_flower:
			missing_2.append("Dried Flower (Garden)" if is_en else "Flor seca (Jardín)")
		if not has_wax:
			missing_2.append("1 Golden Wax" if is_en else "1 Cera dorada")

		if missing_2.is_empty():
			craft_memory_2_button.text = (
				LocaleManager.pick(
					"II. La promesa — [Listo para sellar · Consume 1 Cera]",
					"II. The Promise — [Ready to Seal · Consumes 1 Wax]"
				) if LocaleManager != null else "II. La promesa — [Listo para sellar · Consume 1 Cera]"
			)
			craft_memory_2_button.disabled = false
		else:
			var prefix_2: String = ""
			if is_en:
				prefix_2 = "Missing: "
			else:
				prefix_2 = "Falta: " if missing_2.size() == 1 else "Faltan: "
			var title_2: String = "II. The Promise — " if is_en else "II. La promesa — "
			craft_memory_2_button.text = title_2 + prefix_2 + ", ".join(missing_2)
			craft_memory_2_button.disabled = true

	# --- III. La despedida ---
	if bool(_crafted_memories["the_farewell"]):
		craft_memory_3_button.text = (
			LocaleManager.pick(
				"III. La despedida — [Recuerdo reconstruido ✓]",
				"III. The Farewell — [Memory Reconstructed ✓]"
			) if LocaleManager != null else "III. La despedida — [Recuerdo reconstruido ✓]"
		)
		craft_memory_3_button.disabled = true
	else:
		var missing_3: PackedStringArray = PackedStringArray()
		if not has_last_letter:
			missing_3.append("Last Letter (Bedroom)" if is_en else "Última carta (Habitación)")
		if not has_wax:
			missing_3.append("1 Golden Wax" if is_en else "1 Cera dorada")

		if missing_3.is_empty():
			craft_memory_3_button.text = (
				LocaleManager.pick(
					"III. La despedida — [Listo para sellar · Consume 1 Cera]",
					"III. The Farewell — [Ready to Seal · Consumes 1 Wax]"
				) if LocaleManager != null else "III. La despedida — [Listo para sellar · Consume 1 Cera]"
			)
			craft_memory_3_button.disabled = false
		else:
			var prefix_3: String = ""
			if is_en:
				prefix_3 = "Missing: "
			else:
				prefix_3 = "Falta: " if missing_3.size() == 1 else "Faltan: "
			var title_3: String = "III. The Farewell — " if is_en else "III. La despedida — "
			craft_memory_3_button.text = title_3 + prefix_3 + ", ".join(missing_3)
			craft_memory_3_button.disabled = true


func _on_craft_memory_pressed(memory_key: String) -> void:
	if bool(_crafted_memories.get(memory_key, false)) or WorldState.wax_remaining < 1:
		return

	match memory_key:
		"first_meeting":
			if not (WorldState.clues_found.has("item_photo") and WorldState.clues_found.has("item_letter")):
				return
		"the_promise":
			if not (WorldState.clues_found.has("item_ribbon") and WorldState.clues_found.has("item_dried_flower")):
				return
		"the_farewell":
			if not WorldState.clues_found.has("item_last_letter"):
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
			LocaleManager.pick(
				"El recuerdo se debilita, pero la última chispa del cuaderno te permite abrir el sótano con lo que lograste reunir.",
				"The memory fades, but the notebook's last spark allows you to open the basement with what you gathered."
			) if LocaleManager != null else "El recuerdo se debilita, pero la última chispa del cuaderno te permite abrir el sótano con lo que lograste reunir."
		)
	else:
		_show_notification(
			LocaleManager.pick(
				"¡Los 3 sellos de cera se han abierto! El acceso norte hacia el sótano está desbloqueado.",
				"The 3 wax seals have opened! The northern path into the basement is unlocked."
			) if LocaleManager != null else "¡Los 3 sellos de cera se han abierto! El acceso norte hacia el sótano está desbloqueado."
		)


func _interact_basement_altar() -> void:
	DialogueManager.start_dialogue("sotano_abuelo_inicio")


func _on_wax_fragment_collected(_total: int) -> void:
	_update_hud()
	_show_notification(
		LocaleManager.pick(
			"Has recogido un Fragmento de Cera dorada (+1 Cera disponible).",
			"You collected a Golden Wax Fragment (+1 Wax available)."
		) if LocaleManager != null else "Has recogido un Fragmento de Cera dorada (+1 Cera disponible)."
	)


func _on_clue_registered(_clue_id: String, _total_clues: int) -> void:
	_update_hud()


func _on_dialogue_ended() -> void:
	for child: Node in get_children():
		if child is InspectableObject:
			var obj: InspectableObject = child as InspectableObject
			if not obj.grants_clue_id.is_empty() and WorldState.clues_found.has(obj.grants_clue_id):
				obj._hide_collected_item()

	_update_prompts()
	_update_hud()

	if bool(WorldState.state.get("final_decision_made", false)) and not _is_ending_triggered:
		_is_ending_triggered = true
		call_deferred("_go_to_ending_screen")


func _update_hud() -> void:
	_update_objective_hud()
	if time_label != null:
		time_label.text = (
			LocaleManager.pick("Tiempo del recuerdo: %d", "Memory Time: %d")
			if LocaleManager != null else "Tiempo del recuerdo: %d"
		) % time_units
	if wax_label != null:
		wax_label.text = (
			LocaleManager.pick("Cera dorada: %d", "Golden Wax: %d")
			if LocaleManager != null else "Cera dorada: %d"
		) % WorldState.wax_remaining
	if memories_label != null:
		memories_label.text = (
			LocaleManager.pick("Recuerdos reconstruidos: %d / %d", "Reconstructed Memories: %d / %d")
			if LocaleManager != null else "Recuerdos reconstruidos: %d / %d"
		) % [reconstructed_count, TOTAL_REQUIRED_MEMORIES]

	if items_label != null:
		var is_en: bool = LocaleManager != null and LocaleManager.current_lang == "en"
		var dict_to_use: Dictionary = HOUSE_ITEM_NAMES_EN if is_en else HOUSE_ITEM_NAMES
		var collected_names: PackedStringArray = PackedStringArray()
		for item_key: Variant in dict_to_use.keys():
			var key_str: String = str(item_key)
			if WorldState.clues_found.has(key_str):
				collected_names.append(str(dict_to_use[key_str]))

		if collected_names.is_empty():
			items_label.text = (
				LocaleManager.pick(
					"Objetos de la casa: Ninguno aún (explora el jardín, la sala, el estudio y la habitación)",
					"House Items: None yet (explore the garden, main hall, study, and bedroom)"
				) if LocaleManager != null else "Objetos de la casa: Ninguno aún (explora el jardín, la sala, el estudio y la habitación)"
			)
		else:
			var prefix: String = LocaleManager.pick("Objetos de la casa: ", "House Items: ") if LocaleManager != null else "Objetos de la casa: "
			items_label.text = prefix + ", ".join(collected_names)


func _update_objective_hud() -> void:
	if objective_label == null:
		return

	var has_photo: bool = WorldState.clues_found.has("item_photo")

	if reconstructed_count >= TOTAL_REQUIRED_MEMORIES and _basement_unlocked:
		objective_label.text = (
			LocaleManager.pick(
				"Objetivo: Entra al sótano (norte) y habla con la memoria del abuelo.",
				"Objective: Enter the basement (north) and speak with grandfather's memory."
			) if LocaleManager != null else "Objetivo: Entra al sótano (norte) y habla con la memoria del abuelo."
		)
	elif not has_photo:
		objective_label.text = (
			LocaleManager.pick(
				"Objetivo: Examina la fotografía del abuelo y Elena en la sala principal.",
				"Objective: Examine the photograph of grandfather and Elena in the main hall."
			) if LocaleManager != null else "Objetivo: Examina la fotografía del abuelo y Elena en la sala principal."
		)
	else:
		objective_label.text = (
			LocaleManager.pick(
				"Objetivo: Explora jardín (sur), estudio (oeste) y habitación (este), y sella los recuerdos en la Mesa de Encuadernación (%d/3)." % reconstructed_count,
				"Objective: Explore the garden (south), study (west), and bedroom (east), and seal memories at the Binding Table (%d/3)." % reconstructed_count
			) if LocaleManager != null else "Objetivo: Explora jardín (sur), estudio (oeste) y habitación (este), y sella los recuerdos en la Mesa de Encuadernación (%d/3)." % reconstructed_count
		)


func _show_notification(message: String) -> void:
	if notification_panel == null or notification_label == null or DialogueManager.is_dialogue_active:
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
