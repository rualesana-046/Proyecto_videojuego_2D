class_name WaxFragment
extends Area2D

var _is_collected: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _is_collected:
		return

	if body is Player:
		_is_collected = true
		WorldState.add_wax_fragment()
		queue_free()
