extends Node

signal notebook_state_changed(is_active: bool)
signal wax_fragment_collected(total: int)

const SAVE_PATH: String = "user://savegame.json"

var state: Dictionary = {}
var is_notebook_active: bool = false
var wax_fragments: int = 0
var player_colors: Dictionary = {
	"body": Color.WHITE,
	"hair": Color(0.2, 0.2, 0.2),
	"clothes": Color(0.02, 0.16, 0.14)
}


func toggle_notebook() -> void:
	is_notebook_active = not is_notebook_active
	notebook_state_changed.emit(is_notebook_active)


func add_wax_fragment() -> void:
	wax_fragments += 1
	wax_fragment_collected.emit(wax_fragments)


func reset_wax_fragments() -> void:
	wax_fragments = 0
	wax_fragment_collected.emit(wax_fragments)


func save_game() -> void:
	var serialized_colors: Dictionary = {}
	for part_key: Variant in player_colors.keys():
		var color_value: Color = player_colors[part_key]
		serialized_colors[str(part_key)] = color_value.to_html()

	var save_data: Dictionary = {
		"player_colors": serialized_colors,
		"wax_fragments": wax_fragments,
		"is_notebook_active": is_notebook_active,
		"traits": AIProfiler.traits.duplicate()
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

	return true
