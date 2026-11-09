class_name NPC
extends Area2D

@export var dialogue_id: String = "start"
@export var is_losing_memory: bool = false

var is_player_near: bool = false

@onready var memory_indicator: Sprite2D = $MemoryIndicator


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	WorldState.notebook_state_changed.connect(_on_notebook_state_changed)
	_on_notebook_state_changed(WorldState.is_notebook_active)


func _input(event: InputEvent) -> void:
	if is_player_near and not DialogueManager.is_dialogue_active and event.is_action_pressed("interact"):
		DialogueManager.start_dialogue(dialogue_id)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		is_player_near = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		is_player_near = false


func _on_notebook_state_changed(is_active: bool) -> void:
	memory_indicator.visible = is_losing_memory and is_active
