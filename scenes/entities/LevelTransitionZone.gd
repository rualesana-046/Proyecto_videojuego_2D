class_name LevelTransitionZone
extends Area2D

@export var target_scene_path: String = ""
@export var required_state_key: String = ""
@export_multiline var locked_message: String = "Aún sientes que alguien en la plaza necesita recordar algo importante..."

var _is_transitioning: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _is_transitioning or target_scene_path.is_empty():
		return

	if body is Player:
		if not required_state_key.is_empty() and not bool(WorldState.state.get(required_state_key, false)):
			DialogueManager.show_custom_message("Camino hacia la Antigua Estación", locked_message)
			return

		_is_transitioning = true
		call_deferred("_change_scene")


func _change_scene() -> void:
	WorldState.current_level = target_scene_path
	get_tree().change_scene_to_file(target_scene_path)
