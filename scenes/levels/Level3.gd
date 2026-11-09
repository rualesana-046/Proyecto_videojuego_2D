class_name Level3
extends Node2D

@onready var level_timer: Timer = $LevelTimer
@onready var timer_label: Label = $HUD/TimerLabel
@onready var fragments_label: Label = $HUD/FragmentsLabel


func _ready() -> void:
	level_timer.timeout.connect(_on_level_timer_timeout)
	WorldState.wax_fragment_collected.connect(_on_wax_fragment_collected)
	_on_wax_fragment_collected(WorldState.wax_fragments)
	_update_timer_display()


func _process(_delta: float) -> void:
	_update_timer_display()


func _update_timer_display() -> void:
	var remaining_seconds: int = ceili(level_timer.time_left)
	timer_label.text = "Tiempo restante: %ds" % remaining_seconds


func _on_wax_fragment_collected(total: int) -> void:
	fragments_label.text = "Fragmentos de cera: %d" % total


func _on_level_timer_timeout() -> void:
	WorldState.reset_wax_fragments()
	get_tree().reload_current_scene()
