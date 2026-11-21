class_name PauseMenu
extends CanvasLayer

const MAIN_MENU_PATH: String = "res://scenes/ui/MainMenu.tscn"
const MASTER_BUS_NAME: String = "Master"
const MUSIC_BUS_NAME: String = "Music"
const SFX_BUS_NAME: String = "SFX"

const CHOICE_LABELS: Dictionary = {
	"prologue_silhouette": "Visión en el taller del abuelo"
}

var _save_feedback_tween: Tween = null

@onready var main_pause_panel: PanelContainer = $Overlay/MainPausePanel
@onready var save_feedback_label: Label = $Overlay/MainPausePanel/MarginContainer/VBoxContainer/SaveFeedbackLabel
@onready var resume_button: Button = $Overlay/MainPausePanel/MarginContainer/VBoxContainer/ResumeButton
@onready var save_button: Button = $Overlay/MainPausePanel/MarginContainer/VBoxContainer/SaveButton
@onready var journal_button: Button = $Overlay/MainPausePanel/MarginContainer/VBoxContainer/JournalButton
@onready var options_button: Button = $Overlay/MainPausePanel/MarginContainer/VBoxContainer/OptionsButton
@onready var main_menu_button: Button = $Overlay/MainPausePanel/MarginContainer/VBoxContainer/MainMenuButton
@onready var quit_game_button: Button = $Overlay/MainPausePanel/MarginContainer/VBoxContainer/QuitGameButton

@onready var journal_panel: PanelContainer = $Overlay/JournalPanel
@onready var journal_content_label: RichTextLabel = $Overlay/JournalPanel/MarginContainer/VBoxContainer/ScrollContainer/JournalContentLabel
@onready var close_journal_button: Button = $Overlay/JournalPanel/MarginContainer/VBoxContainer/CloseJournalButton

@onready var options_panel: PanelContainer = $Overlay/OptionsPanel
@onready var master_slider: HSlider = $Overlay/OptionsPanel/MarginContainer/VBoxContainer/MasterRow/MasterSlider
@onready var music_slider: HSlider = $Overlay/OptionsPanel/MarginContainer/VBoxContainer/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $Overlay/OptionsPanel/MarginContainer/VBoxContainer/SfxRow/SfxSlider
@onready var fullscreen_check_button: CheckButton = $Overlay/OptionsPanel/MarginContainer/VBoxContainer/FullscreenCheckButton
@onready var close_options_button: Button = $Overlay/OptionsPanel/MarginContainer/VBoxContainer/CloseOptionsButton

@onready var confirm_main_menu_panel: PanelContainer = $Overlay/ConfirmMainMenuPanel
@onready var confirm_main_menu_yes_button: Button = $Overlay/ConfirmMainMenuPanel/MarginContainer/VBoxContainer/ConfirmMainMenuYesButton
@onready var confirm_main_menu_no_button: Button = $Overlay/ConfirmMainMenuPanel/MarginContainer/VBoxContainer/ConfirmMainMenuNoButton

@onready var confirm_quit_panel: PanelContainer = $Overlay/ConfirmQuitPanel
@onready var confirm_quit_yes_button: Button = $Overlay/ConfirmQuitPanel/MarginContainer/VBoxContainer/ConfirmQuitYesButton
@onready var confirm_quit_no_button: Button = $Overlay/ConfirmQuitPanel/MarginContainer/VBoxContainer/ConfirmQuitNoButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_audio_buses()
	hide()

	resume_button.pressed.connect(_on_resume_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	journal_button.pressed.connect(_on_journal_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	quit_game_button.pressed.connect(_on_quit_game_button_pressed)

	close_journal_button.pressed.connect(_show_main_pause_panel)
	close_options_button.pressed.connect(_show_main_pause_panel)

	master_slider.value_changed.connect(_on_bus_volume_changed.bind(MASTER_BUS_NAME))
	music_slider.value_changed.connect(_on_bus_volume_changed.bind(MUSIC_BUS_NAME))
	sfx_slider.value_changed.connect(_on_bus_volume_changed.bind(SFX_BUS_NAME))
	fullscreen_check_button.toggled.connect(_on_fullscreen_toggled)

	confirm_main_menu_yes_button.pressed.connect(_on_confirm_main_menu_yes_pressed)
	confirm_main_menu_no_button.pressed.connect(_show_main_pause_panel)

	confirm_quit_yes_button.pressed.connect(_on_confirm_quit_yes_pressed)
	confirm_quit_no_button.pressed.connect(_show_main_pause_panel)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible and _is_any_subpanel_open():
			_show_main_pause_panel()
			get_viewport().set_input_as_handled()
			return

		toggle_pause()
		get_viewport().set_input_as_handled()


func toggle_pause() -> void:
	var new_pause_state: bool = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state
	if new_pause_state:
		save_feedback_label.hide()
		_show_main_pause_panel()


func _is_any_subpanel_open() -> bool:
	return (
		journal_panel.visible
		or options_panel.visible
		or confirm_main_menu_panel.visible
		or confirm_quit_panel.visible
	)


func _show_main_pause_panel() -> void:
	journal_panel.hide()
	options_panel.hide()
	confirm_main_menu_panel.hide()
	confirm_quit_panel.hide()
	main_pause_panel.show()


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_save_button_pressed() -> void:
	WorldState.save_game()
	if _save_feedback_tween != null and _save_feedback_tween.is_valid():
		_save_feedback_tween.kill()

	save_feedback_label.text = "Partida guardada"
	save_feedback_label.modulate.a = 1.0
	save_feedback_label.show()

	_save_feedback_tween = create_tween()
	_save_feedback_tween.tween_interval(1.6)
	_save_feedback_tween.tween_property(save_feedback_label, "modulate:a", 0.0, 0.5)
	_save_feedback_tween.tween_callback(save_feedback_label.hide)


func _on_journal_button_pressed() -> void:
	_refresh_journal_display()
	main_pause_panel.hide()
	journal_panel.show()


func _refresh_journal_display() -> void:
	var lines: PackedStringArray = PackedStringArray()

	lines.append("[b][color=#C9AE7C]Personajes conocidos[/color][/b]")
	if WorldState.known_characters.is_empty():
		lines.append("• Aún no has conversado con los habitantes de Aldeavieja.")
	else:
		for character_name: String in WorldState.known_characters:
			lines.append("• " + character_name)

	lines.append("\n[b][color=#C9AE7C]Recuerdos reconstruidos[/color][/b]")
	if WorldState.recovered_memories.is_empty():
		lines.append("• Ningún recuerdo restaurado todavía.")
	else:
		for memory_text: String in WorldState.recovered_memories:
			lines.append("• " + memory_text)

	lines.append("\n[b][color=#C9AE7C]Decisiones importantes[/color][/b]")
	if WorldState.important_choices.is_empty():
		lines.append("• Aún no has tomado decisiones definitivas en el cuaderno.")
	else:
		for choice_key: Variant in WorldState.important_choices.keys():
			var key_str: String = str(choice_key)
			var label_title: String = str(CHOICE_LABELS.get(key_str, key_str.capitalize()))
			var choice_value: String = str(WorldState.important_choices[choice_key])
			lines.append("• [b]%s:[/b] %s" % [label_title, choice_value])

	lines.append("\n[b][color=#C9AE7C]Cera disponible y exploración[/color][/b]")
	lines.append("• Cera restante en el cuaderno: %d" % WorldState.wax_remaining)
	lines.append("• Fragmentos de cera recolectados: %d" % WorldState.wax_fragments)
	lines.append("• Nivel de exploración: %d" % WorldState.exploration_score)

	journal_content_label.text = "\n".join(lines)


func _on_options_button_pressed() -> void:
	_sync_options_controls()
	main_pause_panel.hide()
	options_panel.show()


func _on_main_menu_button_pressed() -> void:
	main_pause_panel.hide()
	confirm_main_menu_panel.show()


func _on_quit_game_button_pressed() -> void:
	main_pause_panel.hide()
	confirm_quit_panel.show()


func _on_confirm_main_menu_yes_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_PATH)


func _on_confirm_quit_yes_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()


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
