class_name Player
extends CharacterBody2D

const SPEED: float = 85.0

@onready var body_sprite: Sprite2D = $Visuals/BodySprite
@onready var clothes_sprite: Sprite2D = $Visuals/ClothesSprite
@onready var hair_sprite: Sprite2D = $Visuals/HairSprite
@onready var camera_2d: Camera2D = $Camera2D


func _ready() -> void:
	apply_colors()
	_configure_camera_limits()


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


func _configure_camera_limits() -> void:
	var parent_node: Node = get_parent()
	if parent_node == null or camera_2d == null:
		return

	var ground_layer: TileMapLayer = parent_node.get_node_or_null("GroundLayer") as TileMapLayer
	if ground_layer == null or ground_layer.tile_set == null:
		return

	var used_rect: Rect2i = ground_layer.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		return

	var tile_size: Vector2i = ground_layer.tile_set.tile_size
	camera_2d.limit_left = used_rect.position.x * tile_size.x
	camera_2d.limit_top = used_rect.position.y * tile_size.y
	camera_2d.limit_right = used_rect.end.x * tile_size.x
	camera_2d.limit_bottom = used_rect.end.y * tile_size.y
