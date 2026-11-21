class_name NPC
extends Area2D

@export var dialogue_id: String = "start"
@export var is_losing_memory: bool = false
@export var next_scene_path: String = ""
@export var npc_texture: Texture2D = null
@export var puzzle_ready_dialogue_id: String = ""
@export var completed_state_key: String = ""
@export var completed_dialogue_id: String = ""

var is_player_near: bool = false
var _awaiting_dialogue_transition: bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var memory_indicator: Sprite2D = $MemoryIndicator
@onready var interact_prompt: Node2D = $InteractPrompt


func _ready() -> void:
	if npc_texture != null and sprite_2d != null:
		sprite_2d.texture = npc_texture

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	WorldState.notebook_state_changed.connect(_on_notebook_state_changed)
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	_on_notebook_state_changed(WorldState.is_notebook_active)
	_update_interact_prompt()


func _input(event: InputEvent) -> void:
	if is_player_near and not DialogueManager.is_dialogue_active and event.is_action_pressed("interact"):
		if not next_scene_path.is_empty():
			_awaiting_dialogue_transition = true

		var active_id: String = _resolve_active_dialogue_id()
		DialogueManager.start_dialogue(active_id)
		get_viewport().set_input_as_handled()


func _resolve_active_dialogue_id() -> String:
	if not completed_state_key.is_empty() and bool(WorldState.state.get(completed_state_key, false)):
		if not completed_dialogue_id.is_empty():
			return completed_dialogue_id

	if not puzzle_ready_dialogue_id.is_empty() and WorldState.has_all_level1_clues():
		return puzzle_ready_dialogue_id

	return dialogue_id


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		is_player_near = true
		_update_interact_prompt()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		is_player_near = false
		_update_interact_prompt()


func _on_notebook_state_changed(is_active: bool) -> void:
	var memory_already_restored: bool = (
		not completed_state_key.is_empty()
		and bool(WorldState.state.get(completed_state_key, false))
	)
	memory_indicator.visible = is_losing_memory and is_active and not memory_already_restored


func _on_dialogue_started() -> void:
	_update_interact_prompt()


func _on_dialogue_ended() -> void:
	_on_notebook_state_changed(WorldState.is_notebook_active)
	_update_interact_prompt()
	if _awaiting_dialogue_transition and not next_scene_path.is_empty():
		_awaiting_dialogue_transition = false
		call_deferred("_transition_to_next_scene")


func _update_interact_prompt() -> void:
	if interact_prompt != null:
		interact_prompt.visible = is_player_near and not DialogueManager.is_dialogue_active


func _transition_to_next_scene() -> void:
	WorldState.current_level = next_scene_path
	get_tree().change_scene_to_file(next_scene_path)
