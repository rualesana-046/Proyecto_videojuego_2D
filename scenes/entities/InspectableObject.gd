class_name InspectableObject
extends Area2D

signal object_inspected(inspected_id: String, used_wax: bool)

const OBJECT_TRANSLATIONS_EN: Dictionary = {
	"plaza_stopped_clock": {
		"name": "Stopped Public Clock",
		"inspect": "The old clock in the central plaza. Its bronze hands remain motionless at a quarter past five.",
		"wax": "Upon opening the Wax Notebook, a golden mark glows upon the clock face: time seemed to stop the afternoon the forgetting began."
	},
	"plaza_bench_no_plaque": {
		"name": "Bench without Plaque",
		"inspect": "A wooden bench facing the fountain. It retains the four rivets of a commemorative plaque that has disappeared.",
		"wax": "The golden wax reveals an invisible dedication carved in the wood: 'For those who guide the first steps without letting go of the hand'."
	},
	"bakery_old_photo": {
		"name": "Old Photograph (Bakery)",
		"inspect": "A framed photograph next to the bakery facade. It shows Lucía smiling, but the figure beside her has completely faded away.",
		"wax": "Bringing the Wax Notebook close, the blurred space clearly outlines the golden silhouette of a bicycle."
	},
	"alley_incomplete_mural": {
		"name": "Incomplete Mural (Alley)",
		"inspect": "A colorful mural in the southwestern alley depicting daily life in Oldtown. One of the painted faces is dissolving into white chalk.",
		"wax": "The Wax Notebook reacts to the lost pigment: when an inhabitant is no longer named, their stroke also fades from the walls."
	},
	"bridge_faded_inscription": {
		"name": "Faded Inscription (Old Bridge)",
		"inspect": "On the railing of the old northern bridge are carved letters almost erased by time: 'Here we learned not to fear falling'.",
		"wax": "The Wax Notebook illuminates the full engraving beside a drawing of two wheels: 'Here we learned not to fear falling — Tomás & Lucía'."
	},
	"station_entrance_posters": {
		"name": "Worn Posters (Entrance)",
		"inspect": "Posters of old railway routes at the station entrance. The names of neighboring stations have faded into illegibility.",
		"wax": "The Wax Notebook reveals the last destination recorded by Samuel: 'Northern Line — Oldtown'."
	},
	"waiting_room_photos": {
		"name": "Old Photographs (Waiting Room)",
		"inspect": "A gallery of portraits of travelers in the waiting room. In several frames, only the empty platform background remains.",
		"wax": "The golden wax reveals your grandfather's silhouette seeing off travelers with a notebook under his arm."
	},
	"waiting_room_schedule": {
		"name": "Timetable Board",
		"inspect": "A wooden board with metal tiles. All departures are marked at the exact time the plaza clock stopped.",
		"wax": "At the bottom of the board a wax note reads: 'Samuel kept the records next to the tower mechanism'."
	},
	"waiting_room_lost_box": {
		"name": "Lost and Found Box",
		"inspect": "A wooden chest full of unstamped tickets, pocket watches without hands, and unaddressed letters.",
		"wax": "Among the items glows a bookbinder's seal identical to the one your grandfather used in his workshop."
	},
	"house_garden_fountain": {
		"name": "Small Garden Fountain",
		"inspect": "A stone fountain covered in dry leaves in the family garden. Though water no longer flows, it retains an aura of peace.",
		"wax": "The golden wax depicts Elena and your grandfather conversing by the stone edge at dusk."
	},
	"house_item_dried_flower": {
		"name": "Dried Garden Flower",
		"inspect": "Among the dried garden plants you find a pressed flower that still retains its petals intact. (You obtained: Dried flower).",
		"wax": "This flower was saved the day they made a promise in the study."
	},
	"house_working_clock": {
		"name": "Main Hall Clock",
		"inspect": "Unlike the plaza and station clocks, this pendulum clock still ticks with a steady heartbeat.",
		"wax": "The Wax Notebook reveals an interior engraving: 'Here time lives on as long as someone remembers'."
	},
	"house_item_photo_elena": {
		"name": "Photograph of Grandfather with Elena",
		"inspect": "A warm photograph on the mantle in the main hall. (You obtained: Photograph).",
		"wax": "The wax shows them smiling together in the study, surrounded by books and golden bindings."
	},
	"house_study_desk": {
		"name": "Study Work Desk",
		"inspect": "The desk where your grandfather researched the Wax Notebook.",
		"wax": "Scattered across the desk are sketches of the three sacred bindings and notes on how memories are sealed."
	},
	"house_item_unfinished_letter": {
		"name": "Unfinished Letter (Study)",
		"inspect": "A sheet of parchment with your grandfather's youthful handwriting: it recounts the day he met Elena among books and tools. (You obtained: Unfinished letter).",
		"wax": "The wax indicates that this letter complements the Photograph in the main hall."
	},
	"house_item_binding_ribbon": {
		"name": "Binding Ribbon (Study)",
		"inspect": "A ribbon woven with golden and moss green thread used to mark the center of the most precious tomes. (You obtained: Binding ribbon).",
		"wax": "Its wax trace resonates with the Dried Flower in the garden."
	},
	"house_item_last_letter": {
		"name": "Last Letter (Grandfather's Bedroom)",
		"inspect": "On the bedroom nightstand rests a sealed envelope with a single written word: 'Elena'. (You obtained: Last letter).",
		"wax": "It holds the memory of the farewell that led your grandfather to seal the town's memories."
	},
	"house_bedroom_keepsakes": {
		"name": "Grandfather's Personal Keepsakes",
		"inspect": "A spare pair of glasses, a pocket watch, and vintage sketches of Oldtown's map.",
		"wax": "On the back of the map it reads: 'The basement will only open to whoever understands our three stages'."
	}
}

@export var object_id: String = ""
@export var object_name: String = "Objeto"
@export_multiline var inspect_text: String = ""
@export_multiline var wax_reveal_text: String = ""
@export var grants_clue_id: String = ""
@export var is_optional_exploration: bool = false
@export var object_texture: Texture2D = null
@export var triggers_dialogue_id: String = ""
@export var hide_after_collect: bool = false
@export var always_show_sparkle: bool = false
@export var collision_radius: float = 0.0

var is_player_near: bool = false
var _is_collected_hidden: bool = false
var _sparkle_tween: Tween = null

@onready var object_sprite: Sprite2D = $ObjectSprite
@onready var wax_sparkle: Sprite2D = $WaxSparkle
@onready var interact_prompt: Node2D = $InteractPrompt


func _ready() -> void:
	if collision_radius > 0.0:
		var col_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
		if col_shape != null:
			var new_shape: CircleShape2D = CircleShape2D.new()
			new_shape.radius = collision_radius
			col_shape.shape = new_shape

	if object_texture != null and object_sprite != null:
		object_sprite.texture = object_texture
		object_sprite.show()

	if wax_sparkle != null:
		_sparkle_tween = create_tween().set_loops()
		_sparkle_tween.tween_property(wax_sparkle, "modulate:a", 0.45, 0.75)
		_sparkle_tween.tween_property(wax_sparkle, "modulate:a", 1.0, 0.75)

	if _is_already_inspected_or_collected():
		if _sparkle_tween != null and _sparkle_tween.is_valid():
			_sparkle_tween.kill()
		if wax_sparkle != null:
			wax_sparkle.hide()
			wax_sparkle.visible = false
		if hide_after_collect and not grants_clue_id.is_empty() and WorldState.clues_found.has(grants_clue_id):
			_hide_collected_item()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	WorldState.notebook_state_changed.connect(_on_notebook_state_changed)
	DialogueManager.dialogue_started.connect(_on_dialogue_state_changed)
	DialogueManager.dialogue_ended.connect(_on_dialogue_state_changed)

	_on_notebook_state_changed(WorldState.is_notebook_active)
	_update_interact_prompt()


func _is_already_inspected_or_collected() -> bool:
	if not object_id.is_empty():
		if WorldState.inspected_objects.has(object_id) or bool(WorldState.state.get("inspected_" + object_id, false)):
			return true
	if not grants_clue_id.is_empty() and WorldState.clues_found.has(grants_clue_id):
		return true
	return false


func _input(event: InputEvent) -> void:
	if _is_collected_hidden:
		return
	if is_player_near and not DialogueManager.is_dialogue_active and event.is_action_pressed("interact"):
		_inspect()
		get_viewport().set_input_as_handled()


func _inspect() -> void:
	var is_first_inspection: bool = false
	if not object_id.is_empty():
		if not WorldState.inspected_objects.has(object_id):
			WorldState.inspected_objects.append(object_id)
			is_first_inspection = true
			if is_optional_exploration:
				WorldState.exploration_score += 1
		WorldState.state["inspected_" + object_id] = true
	else:
		is_first_inspection = true

	var used_wax_reveal: bool = WorldState.is_notebook_active and not wax_reveal_text.is_empty()
	if is_first_inspection:
		object_inspected.emit(object_id, used_wax_reveal)

	if not grants_clue_id.is_empty():
		WorldState.register_clue(grants_clue_id)

	if _sparkle_tween != null and _sparkle_tween.is_valid():
		_sparkle_tween.kill()
	if wax_sparkle != null:
		wax_sparkle.hide()
		wax_sparkle.visible = false

	if hide_after_collect:
		_hide_collected_item()

	if not triggers_dialogue_id.is_empty():
		DialogueManager.start_dialogue(triggers_dialogue_id)
		return

	var resolved_name: String = object_name
	var resolved_inspect: String = inspect_text
	var resolved_wax: String = wax_reveal_text

	if LocaleManager != null and LocaleManager.current_lang == "en" and OBJECT_TRANSLATIONS_EN.has(object_id):
		var trans: Dictionary = OBJECT_TRANSLATIONS_EN[object_id]
		resolved_name = str(trans.get("name", resolved_name))
		resolved_inspect = str(trans.get("inspect", resolved_inspect))
		resolved_wax = str(trans.get("wax", resolved_wax))

	var full_text: String = resolved_inspect
	if used_wax_reveal:
		var wax_prefix: String = LocaleManager.pick("(Cuaderno de Cera): ", "(Wax Notebook): ") if LocaleManager != null else "(Cuaderno de Cera): "
		full_text += "\n\n[color=#C9AE7C][i]" + wax_prefix + resolved_wax + "[/i][/color]"

	DialogueManager.show_custom_message(resolved_name, full_text)


func _hide_collected_item() -> void:
	_is_collected_hidden = true
	is_player_near = false
	monitoring = false
	monitorable = false
	if _sparkle_tween != null and _sparkle_tween.is_valid():
		_sparkle_tween.kill()
	if object_sprite != null:
		object_sprite.hide()
	if wax_sparkle != null:
		wax_sparkle.hide()
		wax_sparkle.visible = false
	if interact_prompt != null:
		interact_prompt.hide()


func _on_body_entered(body: Node2D) -> void:
	if _is_collected_hidden:
		return
	if body is Player:
		is_player_near = true
		_update_interact_prompt()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		is_player_near = false
		_update_interact_prompt()


func _on_notebook_state_changed(is_active: bool) -> void:
	if _is_collected_hidden:
		return
	if _is_already_inspected_or_collected():
		if wax_sparkle != null:
			wax_sparkle.hide()
			wax_sparkle.visible = false
		return

	if wax_sparkle != null:
		var has_hidden_detail: bool = not wax_reveal_text.is_empty() or not grants_clue_id.is_empty()
		wax_sparkle.visible = always_show_sparkle or (is_active and has_hidden_detail)


func _on_dialogue_state_changed() -> void:
	if _is_already_inspected_or_collected():
		if _sparkle_tween != null and _sparkle_tween.is_valid():
			_sparkle_tween.kill()
		if wax_sparkle != null:
			wax_sparkle.hide()
			wax_sparkle.visible = false
		if hide_after_collect and not grants_clue_id.is_empty() and WorldState.clues_found.has(grants_clue_id):
			_hide_collected_item()
	_update_interact_prompt()


func _update_interact_prompt() -> void:
	if interact_prompt != null:
		interact_prompt.visible = (not _is_collected_hidden) and is_player_near and not DialogueManager.is_dialogue_active
