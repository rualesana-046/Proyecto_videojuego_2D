class_name PauseMenu
extends CanvasLayer

const MAIN_MENU_PATH: String = "res://scenes/ui/CharacterCreator.tscn"

@onready var resume_button: Button = $Overlay/PausePanel/VBoxContainer/ResumeButton
@onready var save_button: Button = $Overlay/PausePanel/VBoxContainer/SaveButton
@onready var quit_button: Button = $Overlay/PausePanel/VBoxContainer/QuitButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	resume_button.pressed.connect(_on_resume_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()


func toggle_pause() -> void:
	var new_pause_state: bool = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_save_button_pressed() -> void:
	WorldState.save_game()


func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
