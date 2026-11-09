class_name Level3
extends Node2D

const ENDING_SCREEN_PATH: String = "res://scenes/ui/EndingScreen.tscn"
const REQUIRED_FRAGMENTS: int = 4

var _is_ending_triggered: bool = false

@onready var level_timer: Timer = $LevelTimer
@onready var timer_label: Label = $HUD/TimerLabel
@onready var fragments_label: Label = $HUD/FragmentsLabel


func _ready() -> void:
	WorldState.reset_wax_fragments()
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
	fragments_label.text = "Fragmentos de cera: %d / %d" % [total, REQUIRED_FRAGMENTS]
	if total >= REQUIRED_FRAGMENTS and not _is_ending_triggered:
		_is_ending_triggered = true
		call_deferred("_go_to_ending_screen")


func _on_level_timer_timeout() -> void:
	if not _is_ending_triggered:
		_is_ending_triggered = true
		call_deferred("_go_to_ending_screen")


func _go_to_ending_screen() -> void:
	get_tree().change_scene_to_file(ENDING_SCREEN_PATH)
