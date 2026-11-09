class_name Chaser
extends CharacterBody2D

const SPEED: float = 120.0

var target_player: Player = null

@onready var detection_zone: Area2D = $DetectionZone
@onready var hit_zone: Area2D = $HitZone


func _ready() -> void:
	detection_zone.body_entered.connect(_on_detection_zone_body_entered)
	detection_zone.body_exited.connect(_on_detection_zone_body_exited)
	hit_zone.body_entered.connect(_on_hit_zone_body_entered)


func _physics_process(_delta: float) -> void:
	if is_instance_valid(target_player):
		var direction: Vector2 = global_position.direction_to(target_player.global_position)
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		target_player = body


func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body == target_player:
		target_player = null


func _on_hit_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		call_deferred("_reload_current_scene")


func _reload_current_scene() -> void:
	get_tree().reload_current_scene()
