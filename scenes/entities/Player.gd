class_name Player
extends CharacterBody2D

const SPEED: float = 200.0


func _physics_process(_delta: float) -> void:
	# Input.get_vector devuelve un vector normalizado para evitar mayor velocidad en diagonal.
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	print(direction)
	velocity = direction * SPEED
	move_and_slide()
