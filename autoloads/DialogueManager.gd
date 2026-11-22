extends Node

signal dialogue_started
signal dialogue_ended
signal dialogue_line_updated(speaker_name: String, text: String, options: Array)

const DIALOGUES_ES_PATH: String = "res://assets/data/dialogues.json"
const DIALOGUES_EN_PATH: String = "res://assets/data/dialogues_en.json"

var dialogues: Dictionary = {}
var is_dialogue_active: bool = false
var current_dialogue_id: String = ""


func _ready() -> void:
	load_dialogues()
	if LocaleManager != null:
		LocaleManager.language_changed.connect(_on_language_changed)


func load_dialogues() -> void:
	var path: String = DIALOGUES_EN_PATH if LocaleManager != null and LocaleManager.current_lang == "en" else DIALOGUES_ES_PATH
	if not FileAccess.file_exists(path):
		push_error("Dialogue file not found at path: " + path)
		return

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open dialogue file: " + path)
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

	current_dialogue_id = dialogue_id

	if not is_dialogue_active:
		is_dialogue_active = true
		dialogue_started.emit()

	var node_data: Dictionary = dialogues[dialogue_id]
	_process_node_events(node_data)

	var speaker_name: String = str(node_data.get("speaker", ""))
	var text: String = str(node_data.get("text", ""))
	var options: Array = node_data.get("options", [])

	dialogue_line_updated.emit(speaker_name, text, options)


func show_custom_message(speaker_name: String, text: String, close_label: String = "") -> void:
	var resolved_close: String = close_label
	if resolved_close.is_empty():
		resolved_close = LocaleManager.t("close") if LocaleManager != null else "Cerrar"

	if not is_dialogue_active:
		is_dialogue_active = true
		dialogue_started.emit()

	var single_option: Array = [
		{
			"text": resolved_close,
			"next_id": ""
		}
	]
	dialogue_line_updated.emit(speaker_name, text, single_option)


func _on_language_changed(_new_lang: String) -> void:
	load_dialogues()
	if is_dialogue_active and not current_dialogue_id.is_empty() and dialogues.has(current_dialogue_id):
		var node_data: Dictionary = dialogues[current_dialogue_id]
		var speaker_name: String = str(node_data.get("speaker", ""))
		var text: String = str(node_data.get("text", ""))
		var options: Array = node_data.get("options", [])
		dialogue_line_updated.emit(speaker_name, text, options)


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
	current_dialogue_id = ""
	if is_dialogue_active:
		is_dialogue_active = false
		dialogue_ended.emit()
