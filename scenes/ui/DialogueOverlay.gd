class_name DialogueOverlay
extends CanvasLayer

@onready var dialogue_box: PanelContainer = $DialogueMargin/DialogueAligner/DialogueBox
@onready var speaker_label: Label = $DialogueMargin/DialogueAligner/DialogueBox/MarginContainer/ContentLayout/SpeakerLabel
@onready var speaker_name_label: Label = speaker_label
@onready var dialogue_text_label: RichTextLabel = $DialogueMargin/DialogueAligner/DialogueBox/MarginContainer/ContentLayout/DialogueText
@onready var options_container: VBoxContainer = $DialogueMargin/DialogueAligner/DialogueBox/MarginContainer/ContentLayout/OptionsContainer


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
	speaker_label.text = speaker_name
	dialogue_text_label.text = text
	if not speaker_name.is_empty() and not WorldState.known_characters.has(speaker_name):
		WorldState.known_characters.append(speaker_name)
		WorldState.exploration_score += 1
	_clear_options()
	_create_option_buttons(options)


func _clear_options() -> void:
	for child: Node in options_container.get_children():
		options_container.remove_child(child)
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
		var raw_set_state: Variant = option_data.get("set_state", {})
		var option_set_state: Dictionary = raw_set_state if raw_set_state is Dictionary else {}

		var button: Button = Button.new()
		button.text = option_text
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_on_option_selected.bind(next_id, effect, option_set_state))
		options_container.add_child(button)


func _on_option_selected(next_id: String, effect: Array = [], option_set_state: Dictionary = {}) -> void:
	if not option_set_state.is_empty():
		for state_key: Variant in option_set_state.keys():
			WorldState.state[str(state_key)] = option_set_state[state_key]

	if effect.size() >= 2:
		var trait_name: String = str(effect[0])
		var amount: int = int(effect[1])
		AIProfiler.add_points(trait_name, amount)

	if next_id.is_empty():
		DialogueManager.end_dialogue()
	else:
		DialogueManager.start_dialogue(next_id)
