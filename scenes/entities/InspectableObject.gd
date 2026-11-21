class_name InspectableObject
extends Area2D

@export var object_id: String = ""
@export var object_name: String = "Objeto"
@export_multiline var inspect_text: String = ""
@export_multiline var wax_reveal_text: String = ""
@export var grants_clue_id: String = ""
@export var is_optional_exploration: bool = false
@export var object_texture: Texture2D = null

var is_player_near: bool = false

@onready var object_sprite: Sprite2D = $ObjectSprite
@onready var wax_sparkle: Sprite2D = $WaxSparkle
@onready var interact_prompt: Node2D = $InteractPrompt


func _ready() -> void:
	if object_texture != null and object_sprite != null:
		object_sprite.texture = object_texture
		object_sprite.show()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	WorldState.notebook_state_changed.connect(_on_notebook_state_changed)
	DialogueManager.dialogue_started.connect(_on_dialogue_state_changed)
	DialogueManager.dialogue_ended.connect(_on_dialogue_state_changed)

	_on_notebook_state_changed(WorldState.is_notebook_active)
	_update_interact_prompt()


func _input(event: InputEvent) -> void:
	if is_player_near and not DialogueManager.is_dialogue_active and event.is_action_pressed("interact"):
		_inspect()
		get_viewport().set_input_as_handled()


func _inspect() -> void:
	if not object_id.is_empty() and not WorldState.inspected_objects.has(object_id):
		WorldState.inspected_objects.append(object_id)
		if is_optional_exploration:
			WorldState.exploration_score += 1

	var full_text: String = inspect_text
	if WorldState.is_notebook_active and not wax_reveal_text.is_empty():
		full_text += "\n\n[color=#C9AE7C][i](Cuaderno de Cera): " + wax_reveal_text + "[/i][/color]"

	if not grants_clue_id.is_empty():
		WorldState.register_clue(grants_clue_id)

	DialogueManager.show_custom_message(object_name, full_text)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		is_player_near = true
		_update_interact_prompt()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		is_player_near = false
		_update_interact_prompt()


func _on_notebook_state_changed(is_active: bool) -> void:
	if wax_sparkle != null:
		var has_hidden_detail: bool = not wax_reveal_text.is_empty() or not grants_clue_id.is_empty()
		wax_sparkle.visible = is_active and has_hidden_detail


func _on_dialogue_state_changed() -> void:
	_update_interact_prompt()


func _update_interact_prompt() -> void:
	if interact_prompt != null:
		interact_prompt.visible = is_player_near and not DialogueManager.is_dialogue_active
