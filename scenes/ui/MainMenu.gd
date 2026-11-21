class_name MainMenu
extends Control

const CHARACTER_CREATOR_PATH: String = "res://scenes/ui/CharacterCreator.tscn"
const FIRST_LEVEL_PATH: String = "res://scenes/levels/Level1.tscn"

@onready var new_game_button: Button = $MenuPanel/VBoxContainer/NewGameButton
@onready var load_game_button: Button = $MenuPanel/VBoxContainer/LoadGameButton
@onready var quit_button: Button = $MenuPanel/VBoxContainer/QuitButton


func _ready() -> void:
	load_game_button.disabled = not FileAccess.file_exists(WorldState.SAVE_PATH)
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	load_game_button.pressed.connect(_on_load_game_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)


func _on_new_game_button_pressed() -> void:
	WorldState.reset_state()
	get_tree().change_scene_to_file(CHARACTER_CREATOR_PATH)


func _on_load_game_button_pressed() -> void:
	if WorldState.load_game():
		get_tree().change_scene_to_file(FIRST_LEVEL_PATH)
	else:
		push_warning("No save file found or failed to load save data.")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
