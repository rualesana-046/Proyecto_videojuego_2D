class_name MainMenu
extends Control

const CHARACTER_CREATOR_PATH: String = "res://scenes/ui/CharacterCreator.tscn"
const MASTER_BUS_NAME: String = "Master"
const MUSIC_BUS_NAME: String = "Music"
const SFX_BUS_NAME: String = "SFX"

var _intro_tween: Tween = null
var _is_intro_playing: bool = false

@onready var intro_title_overlay: VBoxContainer = $IntroTitleOverlay
@onready var menu_panel: PanelContainer = $MenuPanel
@onready var new_game_button: Button = $MenuPanel/MarginContainer/VBoxContainer/NewGameButton
@onready var continue_button: Button = $MenuPanel/MarginContainer/VBoxContainer/ContinueButton
@onready var options_button: Button = $MenuPanel/MarginContainer/VBoxContainer/OptionsButton
@onready var quit_button: Button = $MenuPanel/MarginContainer/VBoxContainer/QuitButton

@onready var options_modal: ColorRect = $OptionsModal
@onready var options_panel: PanelContainer = $OptionsModal/OptionsPanel
@onready var master_slider: HSlider = $OptionsModal/OptionsPanel/MarginContainer/VBoxContainer/MasterRow/MasterSlider
@onready var music_slider: HSlider = $OptionsModal/OptionsPanel/MarginContainer/VBoxContainer/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $OptionsModal/OptionsPanel/MarginContainer/VBoxContainer/SfxRow/SfxSlider
@onready var fullscreen_check_button: CheckButton = $OptionsModal/OptionsPanel/MarginContainer/VBoxContainer/FullscreenCheckButton
@onready var tutorial_button: Button = $OptionsModal/OptionsPanel/MarginContainer/VBoxContainer/TutorialButton
@onready var close_options_button: Button = $OptionsModal/OptionsPanel/MarginContainer/VBoxContainer/CloseOptionsButton
@onready var tutorial_panel: PanelContainer = $OptionsModal/TutorialPanel
@onready var close_tutorial_button: Button = $OptionsModal/TutorialPanel/MarginContainer/VBoxContainer/CloseTutorialButton


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
	tutorial_button.pressed.connect(_on_tutorial_button_pressed)
	close_tutorial_button.pressed.connect(_on_close_tutorial_button_pressed)
	close_options_button.pressed.connect(_on_close_options_button_pressed)

	_start_intro_sequence()


func _input(event: InputEvent) -> void:
	if not _is_intro_playing:
		return

	var is_skip_pressed: bool = (
		event.is_action_pressed("ui_accept")
		or event.is_action_pressed("ui_cancel")
		or (event is InputEventKey and event.pressed and not event.echo)
		or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	)
	if is_skip_pressed:
		_skip_intro_sequence()
		get_viewport().set_input_as_handled()


func _start_intro_sequence() -> void:
	_is_intro_playing = true
	menu_panel.visible = false
	menu_panel.modulate.a = 0.0
	intro_title_overlay.visible = true
	intro_title_overlay.modulate.a = 0.0

	_intro_tween = create_tween()
	_intro_tween.tween_property(intro_title_overlay, "modulate:a", 1.0, 1.2)
	_intro_tween.tween_interval(1.8)
	_intro_tween.tween_property(intro_title_overlay, "modulate:a", 0.0, 0.6)
	_intro_tween.tween_callback(_show_menu_panel_for_fade)
	_intro_tween.tween_property(menu_panel, "modulate:a", 1.0, 0.8)
	_intro_tween.tween_callback(_on_intro_sequence_finished)


func _show_menu_panel_for_fade() -> void:
	intro_title_overlay.visible = false
	menu_panel.visible = true


func _on_intro_sequence_finished() -> void:
	_is_intro_playing = false


func _skip_intro_sequence() -> void:
	if _intro_tween != null and _intro_tween.is_valid():
		_intro_tween.kill()
	_is_intro_playing = false
	intro_title_overlay.visible = false
	intro_title_overlay.modulate.a = 0.0
	menu_panel.visible = true
	menu_panel.modulate.a = 1.0


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
	_sync_options_controls()
	tutorial_panel.hide()
	options_panel.show()
	options_modal.show()


func _on_tutorial_button_pressed() -> void:
	options_panel.hide()
	tutorial_panel.show()


func _on_close_tutorial_button_pressed() -> void:
	tutorial_panel.hide()
	options_panel.show()


func _on_close_options_button_pressed() -> void:
	tutorial_panel.hide()
	options_modal.hide()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
