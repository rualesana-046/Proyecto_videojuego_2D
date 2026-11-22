class_name Chaser
extends CharacterBody2D

signal player_caught(player_body: Player)

const SPEED: float = 55.0

@export var starts_active: bool = true

var target_player: Player = null
var is_active: bool = true
var is_distracted: bool = false
var _distraction_target: Vector2 = Vector2.ZERO
var _distraction_timer: float = 0.0
var _catch_cooldown: float = 0.0

@onready var detection_zone: Area2D = $DetectionZone
@onready var hit_zone: Area2D = $HitZone
@onready var whisper_container: Node2D = $WhisperContainer
@onready var whisper_label: Label = $WhisperContainer/WhisperPanel/WhisperLabel


func _ready() -> void:
	detection_zone.body_entered.connect(_on_detection_zone_body_entered)
	detection_zone.body_exited.connect(_on_detection_zone_body_exited)
	hit_zone.body_entered.connect(_on_hit_zone_body_entered)
	DialogueManager.dialogue_started.connect(_on_dialogue_state_changed)
	DialogueManager.dialogue_ended.connect(_on_dialogue_state_changed)

	if whisper_container != null:
		whisper_container.hide()

	set_active_state(starts_active)


func _on_dialogue_state_changed() -> void:
	if DialogueManager.is_dialogue_active:
		velocity = Vector2.ZERO


func set_active_state(active: bool) -> void:
	is_active = active
	visible = active
	if not active:
		velocity = Vector2.ZERO
		is_distracted = false


func activate_at(spawn_position: Vector2) -> void:
	global_position = spawn_position
	modulate.a = 1.0
	if whisper_container != null:
		whisper_container.hide()
	set_active_state(true)


func distract_to(target_pos: Vector2, duration: float) -> void:
	if not is_active:
		return
	is_distracted = true
	_distraction_target = target_pos
	_distraction_timer = duration


func vanish_with_whisper(whisper_text: String = "Olvido") -> void:
	is_active = false
	is_distracted = false
	velocity = Vector2.ZERO

	if whisper_label != null:
		whisper_label.text = whisper_text
	if whisper_container != null:
		whisper_container.show()

	var tween: Tween = create_tween()
	tween.tween_interval(1.4)
	tween.tween_property(self, "modulate:a", 0.0, 1.4)
	tween.tween_callback(hide)


func _physics_process(delta: float) -> void:
	if not is_active or DialogueManager.is_dialogue_active:
		velocity = Vector2.ZERO
		return

	if _catch_cooldown > 0.0:
		_catch_cooldown -= delta
	elif hit_zone != null:
		for body: Node2D in hit_zone.get_overlapping_bodies():
			if body is Player:
				_on_hit_zone_body_entered(body)
				return

	if not is_instance_valid(target_player) and detection_zone != null:
		for body: Node2D in detection_zone.get_overlapping_bodies():
			if body is Player:
				target_player = body as Player
				break

	if is_distracted:
		_distraction_timer -= delta
		if global_position.distance_to(_distraction_target) > 6.0:
			var distract_dir: Vector2 = global_position.direction_to(_distraction_target)
			velocity = distract_dir * SPEED
		else:
			velocity = Vector2.ZERO

		if _distraction_timer <= 0.0:
			is_distracted = false

		move_and_slide()
		return

	if is_instance_valid(target_player):
		var direction: Vector2 = global_position.direction_to(target_player.global_position)
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func _on_detection_zone_body_entered(body: Node2D) -> void:
	if DialogueManager.is_dialogue_active:
		return
	if body is Player:
		target_player = body


func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body == target_player:
		target_player = null


func _on_hit_zone_body_entered(body: Node2D) -> void:
	if not is_active or _catch_cooldown > 0.0 or DialogueManager.is_dialogue_active:
		return

	if body is Player:
		_catch_cooldown = 1.5
		if player_caught.get_connections().size() > 0:
			player_caught.emit(body as Player)
		else:
			call_deferred("_reload_current_scene")


func _reload_current_scene() -> void:
	get_tree().reload_current_scene()
