class_name MainMenu
extends Control

const CHARACTER_CREATOR_PATH: String = "res://scenes/ui/CharacterCreator.tscn"
const MASTER_BUS_NAME: String = "Master"
const MUSIC_BUS_NAME: String = "Music"
const SFX_BUS_NAME: String = "SFX"

@onready var new_game_button: Button = $MenuPanel/MarginContainer/VBoxContainer/NewGameButton
@onready var continue_button: Button = $MenuPanel/MarginContainer/VBoxContainer/ContinueButton
@onready var options_button: Button = $MenuPanel/MarginContainer/VBoxContainer/OptionsButton
@onready var quit_button: Button = $MenuPanel/MarginContainer/VBoxContainer/QuitButton

@onready var options_modal: ColorRect = $OptionsModal
@onready var master_slider: HSlider = $OptionsModal/OptionsPanel/MarginContainer/VBoxContainer/MasterRow/MasterSlider
@onready var music_slider: HSlider = $OptionsModal/OptionsPanel/MarginContainer/VBoxContainer/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $OptionsModal/OptionsPanel/MarginContainer/VBoxContainer/SfxRow/SfxSlider
@onready var fullscreen_check_button: CheckButton = $OptionsModal/OptionsPanel/MarginContainer/VBoxContainer/FullscreenCheckButton
@onready var close_options_button: Button = $OptionsModal/OptionsPanel/MarginContainer/VBoxContainer/CloseOptionsButton


func _ready() -> void:
	_ensure_audio_buses()
	_sync_options_controls()

	continue_button.disabled = not FileAccess.file_exists(WorldState.SAVE_PATH)

	new_game_button.pressed.connect(_on_new_game_button_pressed)
	continue_button.pressed.connect(_on_continue_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

	master_slider.value_changed.connect(_on_bus_volume_changed.bind(MASTER_BUS_NAME))
	music_slider.value_changed.connect(_on_bus_volume_changed.bind(MUSIC_BUS_NAME))
	sfx_slider.value_changed.connect(_on_bus_volume_changed.bind(SFX_BUS_NAME))
	fullscreen_check_button.toggled.connect(_on_fullscreen_toggled)
	close_options_button.pressed.connect(_on_close_options_button_pressed)


func _ensure_audio_buses() -> void:
	for bus_name: String in [MUSIC_BUS_NAME, SFX_BUS_NAME]:
		if AudioServer.get_bus_index(bus_name) == -1:
			var new_index: int = AudioServer.bus_count
			AudioServer.add_bus(new_index)
			AudioServer.set_bus_name(new_index, bus_name)
			AudioServer.set_bus_send(new_index, MASTER_BUS_NAME)


func _sync_options_controls() -> void:
	master_slider.value = _get_bus_linear_volume(MASTER_BUS_NAME)
	music_slider.value = _get_bus_linear_volume(MUSIC_BUS_NAME)
	sfx_slider.value = _get_bus_linear_volume(SFX_BUS_NAME)
	var current_mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
	fullscreen_check_button.button_pressed = (
		current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN
		or current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	)


func _get_bus_linear_volume(bus_name: String) -> float:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx == -1 or AudioServer.is_bus_mute(bus_idx):
		return 0.0
	return clampf(db_to_linear(AudioServer.get_bus_volume_db(bus_idx)), 0.0, 1.0)


func _on_bus_volume_changed(value: float, bus_name: String) -> void:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		return

	if value <= 0.001:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_new_game_button_pressed() -> void:
	WorldState.reset_state()
	get_tree().change_scene_to_file(CHARACTER_CREATOR_PATH)


func _on_continue_button_pressed() -> void:
	if WorldState.load_game():
		get_tree().change_scene_to_file(WorldState.current_level)
	else:
		push_warning("No save file found or failed to load save data.")


func _on_options_button_pressed() -> void:
	options_modal.show()


func _on_close_options_button_pressed() -> void:
	options_modal.hide()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
