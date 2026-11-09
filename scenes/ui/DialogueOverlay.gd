class_name DialogueOverlay
extends CanvasLayer

@onready var speaker_name_label: Label = $UIContainer/DialogueBox/SpeakerName
@onready var dialogue_text_label: RichTextLabel = $UIContainer/DialogueBox/DialogueText
@onready var options_container: HBoxContainer = $UIContainer/DialogueBox/OptionsContainer


func _ready() -> void:
	hide()
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.dialogue_line_updated.connect(_on_dialogue_line_updated)


func _on_dialogue_started() -> void:
	show()


func _on_dialogue_ended() -> void:
	_clear_options()
	hide()


func _on_dialogue_line_updated(speaker_name: String, text: String, options: Array) -> void:
	show()
	speaker_name_label.text = speaker_name
	dialogue_text_label.text = text
	_clear_options()
	_create_option_buttons(options)


func _clear_options() -> void:
	for child: Node in options_container.get_children():
		child.queue_free()


func _create_option_buttons(options: Array) -> void:
	for option_variant: Variant in options:
		if not (option_variant is Dictionary):
			continue

		var option_data: Dictionary = option_variant
		var option_text: String = str(option_data.get("text", ""))
		var next_id: String = str(option_data.get("next_id", ""))
		var raw_effect: Variant = option_data.get("effect", [])
		var effect: Array = raw_effect if raw_effect is Array else []

		var button: Button = Button.new()
		button.text = option_text
		button.pressed.connect(_on_option_selected.bind(next_id, effect))
		options_container.add_child(button)


func _on_option_selected(next_id: String, effect: Array = []) -> void:
	if effect.size() >= 2:
		var trait_name: String = str(effect[0])
		var amount: int = int(effect[1])
		AIProfiler.add_points(trait_name, amount)

	if next_id.is_empty():
		DialogueManager.end_dialogue()
	else:
		DialogueManager.start_dialogue(next_id)
