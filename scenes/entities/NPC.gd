class_name NPC
extends Area2D

@export var dialogue_id: String = "start"

var is_player_near: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _input(event: InputEvent) -> void:
	if is_player_near and not DialogueManager.is_dialogue_active and event.is_action_pressed("interact"):
		DialogueManager.start_dialogue(dialogue_id)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		is_player_near = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		is_player_near = false
