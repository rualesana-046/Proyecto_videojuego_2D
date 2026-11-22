class_name InspectableObject
extends Area2D

signal object_inspected(inspected_id: String, used_wax: bool)

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

	if hide_after_collect and not grants_clue_id.is_empty() and WorldState.clues_found.has(grants_clue_id):
		_hide_collected_item()

	if wax_sparkle != null:
		var spark_tween: Tween = create_tween().set_loops()
		spark_tween.tween_property(wax_sparkle, "modulate:a", 0.45, 0.75)
		spark_tween.tween_property(wax_sparkle, "modulate:a", 1.0, 0.75)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	WorldState.notebook_state_changed.connect(_on_notebook_state_changed)
	DialogueManager.dialogue_started.connect(_on_dialogue_state_changed)
	DialogueManager.dialogue_ended.connect(_on_dialogue_state_changed)

	_on_notebook_state_changed(WorldState.is_notebook_active)
	_update_interact_prompt()


func _input(event: InputEvent) -> void:
	if _is_collected_hidden:
		return
	if is_player_near and not DialogueManager.is_dialogue_active and event.is_action_pressed("interact"):
		_inspect()
		get_viewport().set_input_as_handled()


func _inspect() -> void:
	var is_first_inspection: bool = false
	if not object_id.is_empty() and not WorldState.inspected_objects.has(object_id):
		WorldState.inspected_objects.append(object_id)
		is_first_inspection = true
		if is_optional_exploration:
			WorldState.exploration_score += 1

	var used_wax_reveal: bool = WorldState.is_notebook_active and not wax_reveal_text.is_empty()
	if is_first_inspection:
		object_inspected.emit(object_id, used_wax_reveal)

	if not grants_clue_id.is_empty():
		WorldState.register_clue(grants_clue_id)

	if hide_after_collect:
		_hide_collected_item()

	if not triggers_dialogue_id.is_empty():
		DialogueManager.start_dialogue(triggers_dialogue_id)
		return

	var full_text: String = inspect_text
	if used_wax_reveal:
		full_text += "\n\n[color=#C9AE7C][i](Cuaderno de Cera): " + wax_reveal_text + "[/i][/color]"

	DialogueManager.show_custom_message(object_name, full_text)


func _hide_collected_item() -> void:
	_is_collected_hidden = true
	is_player_near = false
	if object_sprite != null:
		object_sprite.hide()
	if wax_sparkle != null:
		wax_sparkle.hide()
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
	if wax_sparkle != null:
		var has_hidden_detail: bool = not wax_reveal_text.is_empty() or not grants_clue_id.is_empty()
		wax_sparkle.visible = always_show_sparkle or (is_active and has_hidden_detail)


func _on_dialogue_state_changed() -> void:
	_update_interact_prompt()


func _update_interact_prompt() -> void:
	if interact_prompt != null:
		interact_prompt.visible = (not _is_collected_hidden) and is_player_near and not DialogueManager.is_dialogue_active
