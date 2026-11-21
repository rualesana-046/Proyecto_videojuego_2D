extends Node

signal notebook_state_changed(is_active: bool)
signal wax_fragment_collected(total: int)
signal clue_registered(clue_id: String, total_clues: int)
signal memory_reconstructed(memory_id: String)
signal status_notification_requested(message: String)

const SAVE_PATH: String = "user://savegame.json"
const DEFAULT_LEVEL_PATH: String = "res://scenes/levels/Level1.tscn"
const DEFAULT_WAX_REMAINING: int = 5
const LEVEL1_REQUIRED_CLUES: Array[String] = [
	"clue_photo",
	"clue_paper_flower",
	"clue_bridge"
]

var state: Dictionary = {}
var is_notebook_active: bool = false
var wax_fragments: int = 0
var player_colors: Dictionary = {
	"body": Color.WHITE,
	"hair": Color(0.2, 0.2, 0.2),
	"clothes": Color(0.02, 0.16, 0.14)
}

var recovered_memories: Array[String] = []
var known_characters: Array[String] = []
var important_choices: Dictionary = {}
var exploration_score: int = 0
var time_management: Dictionary = {}
var narrative_profile: String = "nostalgia"
var wax_remaining: int = DEFAULT_WAX_REMAINING
var current_level: String = DEFAULT_LEVEL_PATH
var clues_found: Array[String] = []
var inspected_objects: Array[String] = []


func toggle_notebook() -> void:
	is_notebook_active = not is_notebook_active
	notebook_state_changed.emit(is_notebook_active)


func add_wax_fragment() -> void:
	wax_fragments += 1
	wax_remaining += 1
	wax_fragment_collected.emit(wax_fragments)


func reset_wax_fragments() -> void:
	wax_fragments = 0
	wax_fragment_collected.emit(wax_fragments)


func register_clue(clue_id: String) -> bool:
	if clue_id.is_empty() or clues_found.has(clue_id):
		return false

	clues_found.append(clue_id)
	clue_registered.emit(clue_id, clues_found.size())

	if has_all_level1_clues() and not bool(state.get("lucia_tomas_reconstructed", false)):
		if not bool(state.get("level1_clues_notified", false)):
			state["level1_clues_notified"] = true
			status_notification_requested.emit(
				"El Cuaderno de Cera brilla... vuelve con Lucía para reconstruir el recuerdo."
			)
	return true


func has_all_level1_clues() -> bool:
	for req_clue: String in LEVEL1_REQUIRED_CLUES:
		if not clues_found.has(req_clue):
			return false
	return true


func register_recovered_memory(memory_title: String) -> void:
	if memory_title.is_empty():
		return
	if not recovered_memories.has(memory_title):
		recovered_memories.append(memory_title)
	memory_reconstructed.emit(memory_title)


func reset_state() -> void:
	state.clear()
	is_notebook_active = false
	notebook_state_changed.emit(is_notebook_active)
	reset_wax_fragments()
	recovered_memories.clear()
	known_characters.clear()
	important_choices.clear()
	exploration_score = 0
	time_management.clear()
	narrative_profile = "nostalgia"
	wax_remaining = DEFAULT_WAX_REMAINING
	current_level = DEFAULT_LEVEL_PATH
	clues_found.clear()
	inspected_objects.clear()
	AIProfiler.reset_traits()


func save_game() -> void:
	narrative_profile = AIProfiler.get_dominant_profile()

	var serialized_colors: Dictionary = {}
	for part_key: Variant in player_colors.keys():
		var color_value: Color = player_colors[part_key]
		serialized_colors[str(part_key)] = color_value.to_html()

	var save_data: Dictionary = {
		"state": state.duplicate(true),
		"player_colors": serialized_colors,
		"wax_fragments": wax_fragments,
		"is_notebook_active": is_notebook_active,
		"traits": AIProfiler.traits.duplicate(),
		"recovered_memories": recovered_memories.duplicate(),
		"known_characters": known_characters.duplicate(),
		"important_choices": important_choices.duplicate(true),
		"exploration_score": exploration_score,
		"time_management": time_management.duplicate(true),
		"narrative_profile": narrative_profile,
		"wax_remaining": wax_remaining,
		"current_level": current_level,
		"clues_found": clues_found.duplicate(),
		"inspected_objects": inspected_objects.duplicate()
	}

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file for writing: " + SAVE_PATH)
		return

	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	print("Game saved successfully to: " + SAVE_PATH)


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file for reading: " + SAVE_PATH)
		return false

	var json_text: String = file.get_as_text()
	file.close()

	var parsed_data: Variant = JSON.parse_string(json_text)
	if not (parsed_data is Dictionary):
		push_error("Invalid save file format.")
		return false

	var save_data: Dictionary = parsed_data

	var saved_state_variant: Variant = save_data.get("state", {})
	state = saved_state_variant.duplicate(true) if saved_state_variant is Dictionary else {}

	var saved_colors_variant: Variant = save_data.get("player_colors", {})
	if saved_colors_variant is Dictionary:
		var saved_colors: Dictionary = saved_colors_variant
		for part_key: Variant in saved_colors.keys():
			var hex_string: String = str(saved_colors[part_key])
			player_colors[str(part_key)] = Color(hex_string)

	wax_fragments = int(save_data.get("wax_fragments", 0))
	wax_fragment_collected.emit(wax_fragments)

	is_notebook_active = bool(save_data.get("is_notebook_active", false))
	notebook_state_changed.emit(is_notebook_active)

	var saved_traits_variant: Variant = save_data.get("traits", {})
	if saved_traits_variant is Dictionary:
		var saved_traits: Dictionary = saved_traits_variant
		for trait_key: Variant in saved_traits.keys():
			var key_name: String = str(trait_key)
			if AIProfiler.traits.has(key_name):
				AIProfiler.traits[key_name] = int(saved_traits[trait_key])

	recovered_memories.clear()
	var saved_memories_variant: Variant = save_data.get("recovered_memories", [])
	if saved_memories_variant is Array:
		for item: Variant in saved_memories_variant:
			recovered_memories.append(str(item))

	known_characters.clear()
	var saved_characters_variant: Variant = save_data.get("known_characters", [])
	if saved_characters_variant is Array:
		for item: Variant in saved_characters_variant:
			known_characters.append(str(item))

	var saved_choices_variant: Variant = save_data.get("important_choices", {})
	important_choices = saved_choices_variant.duplicate(true) if saved_choices_variant is Dictionary else {}

	exploration_score = int(save_data.get("exploration_score", 0))

	var saved_time_variant: Variant = save_data.get("time_management", {})
	time_management = saved_time_variant.duplicate(true) if saved_time_variant is Dictionary else {}

	narrative_profile = str(save_data.get("narrative_profile", AIProfiler.get_dominant_profile()))
	wax_remaining = int(save_data.get("wax_remaining", DEFAULT_WAX_REMAINING))
	current_level = str(save_data.get("current_level", DEFAULT_LEVEL_PATH))
	if current_level.is_empty():
		current_level = DEFAULT_LEVEL_PATH

	clues_found.clear()
	var saved_clues_variant: Variant = save_data.get("clues_found", [])
	if saved_clues_variant is Array:
		for item: Variant in saved_clues_variant:
			clues_found.append(str(item))

	inspected_objects.clear()
	var saved_inspected_variant: Variant = save_data.get("inspected_objects", [])
	if saved_inspected_variant is Array:
		for item: Variant in saved_inspected_variant:
			inspected_objects.append(str(item))

	return true
