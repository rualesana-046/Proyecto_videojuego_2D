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
	var speaker_name: String = str(node_data.get("speaker", ""))
	var text: String = str(node_data.get("text", ""))
	var options: Array = node_data.get("options", [])

	dialogue_line_updated.emit(speaker_name, text, options)


func end_dialogue() -> void:
	if is_dialogue_active:
		is_dialogue_active = false
		dialogue_ended.emit()
