class_name LevelTransitionZone
extends Area2D

@export var target_scene_path: String = ""

var _is_transitioning: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _is_transitioning or target_scene_path.is_empty():
		return

	if body is Player:
		_is_transitioning = true
		call_deferred("_change_scene")


func _change_scene() -> void:
	get_tree().change_scene_to_file(target_scene_path)
