extends Node

signal dialogue_started
signal dialogue_ended
signal dialogue_line_updated(speaker_name: String, text: String, options: Array)

const DIALOGUES_FILE_PATH: String = "res://assets/data/dialogues.json"

var dialogues: Dictionary = {}
var is_dialogue_active: bool = false


func _ready() -> void:
	load_dialogues()


func load_dialogues() -> void:
	if not FileAccess.file_exists(DIALOGUES_FILE_PATH):
		push_error("Dialogue file not found at path: " + DIALOGUES_FILE_PATH)
		return

	var file: FileAccess = FileAccess.open(DIALOGUES_FILE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open dialogue file: " + DIALOGUES_FILE_PATH)
		return

	var json_text: String = file.get_as_text()
	file.close()

	var parsed_data: Variant = JSON.parse_string(json_text)
	if parsed_data is Dictionary:
		dialogues = parsed_data
	else:
		push_error("Invalid JSON structure in dialogue file: expected a Dictionary.")


func start_dialogue(dialogue_id: String) -> void:
	if dialogue_id.is_empty():
		end_dialogue()
		return

	if not dialogues.has(dialogue_id):
		push_warning("Dialogue ID not found: " + dialogue_id)
		end_dialogue()
		return

	if not is_dialogue_active:
		is_dialogue_active = true
		dialogue_started.emit()

	var node_data: Dictionary = dialogues[dialogue_id]
	_process_node_events(node_data)

	var speaker_name: String = str(node_data.get("speaker", ""))
	var text: String = str(node_data.get("text", ""))
	var options: Array = node_data.get("options", [])

	dialogue_line_updated.emit(speaker_name, text, options)


func show_custom_message(speaker_name: String, text: String, close_label: String = "Cerrar") -> void:
	if not is_dialogue_active:
		is_dialogue_active = true
		dialogue_started.emit()

	var single_option: Array = [
		{
			"text": close_label,
			"next_id": ""
		}
	]
	dialogue_line_updated.emit(speaker_name, text, single_option)


func _process_node_events(node_data: Dictionary) -> void:
	if node_data.has("grant_clue"):
		var clue_id: String = str(node_data["grant_clue"])
		WorldState.register_clue(clue_id)

	if node_data.has("unlock_memory"):
		var memory_title: String = str(node_data["unlock_memory"])
		WorldState.register_recovered_memory(memory_title)

	if node_data.has("set_state") and node_data["set_state"] is Dictionary:
		var state_updates: Dictionary = node_data["set_state"]
		for state_key: Variant in state_updates.keys():
			WorldState.state[str(state_key)] = state_updates[state_key]

	if node_data.has("important_choice") and node_data["important_choice"] is Array:
		var choice_pair: Array = node_data["important_choice"]
		if choice_pair.size() >= 2:
			WorldState.important_choices[str(choice_pair[0])] = str(choice_pair[1])

	if node_data.has("consume_wax"):
		var wax_cost: int = int(node_data["consume_wax"])
		WorldState.wax_remaining = maxi(0, WorldState.wax_remaining - wax_cost)


func end_dialogue() -> void:
	if is_dialogue_active:
		is_dialogue_active = false
		dialogue_ended.emit()
