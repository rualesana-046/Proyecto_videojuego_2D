class_name Player
extends CharacterBody2D

const SPEED: float = 200.0

@onready var body_sprite: Sprite2D = $Visuals/BodySprite
@onready var clothes_sprite: Sprite2D = $Visuals/ClothesSprite
@onready var hair_sprite: Sprite2D = $Visuals/HairSprite


func _ready() -> void:
	apply_colors()


func _physics_process(_delta: float) -> void:
	# Input.get_vector devuelve un vector normalizado para evitar mayor velocidad en diagonal.
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_notebook"):
		WorldState.toggle_notebook()
	elif event.is_action_pressed("quick_save"):
		WorldState.save_game()


func apply_colors() -> void:
	body_sprite.modulate = WorldState.player_colors.get("body", Color.WHITE)
	clothes_sprite.modulate = WorldState.player_colors.get("clothes", Color(0.02, 0.16, 0.14))
	hair_sprite.modulate = WorldState.player_colors.get("hair", Color(0.2, 0.2, 0.2))
