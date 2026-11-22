class_name CreditsScreen
extends Control

const MAIN_MENU_PATH: String = "res://scenes/ui/MainMenu.tscn"
const ENDING_SCREEN_PATH: String = "res://scenes/ui/EndingScreen.tscn"

var _sequence_tween: Tween = null
var _current_section_index: int = 0
var _is_showing_final_card: bool = false

@onready var sequence_container: VBoxContainer = $CreditsPanel/MarginContainer/SequenceContainer
@onready var section_title_label: Label = $CreditsPanel/MarginContainer/SequenceContainer/SectionTitleLabel
@onready var section_body_label: RichTextLabel = $CreditsPanel/MarginContainer/SequenceContainer/SectionBodyLabel
@onready var skip_button: Button = $CreditsPanel/MarginContainer/SequenceContainer/SkipButton

@onready var final_card_container: VBoxContainer = $CreditsPanel/MarginContainer/FinalCardContainer
@onready var closing_title_label: Label = $CreditsPanel/MarginContainer/FinalCardContainer/ClosingTitleLabel
@onready var closing_subtitle_label: Label = $CreditsPanel/MarginContainer/FinalCardContainer/ClosingSubtitleLabel
@onready var main_menu_button: Button = $CreditsPanel/MarginContainer/FinalCardContainer/MainMenuButton
@onready var replay_ending_button: Button = $CreditsPanel/MarginContainer/FinalCardContainer/ReplayEndingButton
@onready var quit_game_button: Button = $CreditsPanel/MarginContainer/FinalCardContainer/QuitGameButton


func _ready() -> void:
	for btn: Button in [skip_button, main_menu_button, replay_ending_button, quit_game_button]:
		btn.pressed.connect(AudioManager.play_ui_click)

	skip_button.pressed.connect(_show_final_card)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	replay_ending_button.pressed.connect(_on_replay_ending_button_pressed)
	quit_game_button.pressed.connect(_on_quit_game_button_pressed)

	if LocaleManager != null:
		LocaleManager.language_changed.connect(_on_language_changed)

	_update_locale_texts()
	_start_credits_sequence()


func _unhandled_input(event: InputEvent) -> void:
	if _is_showing_final_card:
		return

	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_show_final_card()
		get_viewport().set_input_as_handled()


func _get_localized_credits_sections() -> Array[Dictionary]:
	if LocaleManager == null:
		return [
			{
				"title": "Desarrollo",
				"body": "[center]Ana María Ruales\nProgramación y arquitectura en Godot Engine 4 (GDScript)[/center]"
			},
			{
				"title": "Diseño narrativo",
				"body": "[center]Ana María Ruales\nHistoria original, diálogos y sistema de decisiones[/center]"
			},
			{
				"title": "Diseño visual",
				"body": "[center]Ana María Ruales\nDirección de arte, interfaz ornamental y sprites 2D\nIlustraciones conceptuales asistidas con Gemini\nTipografías Almendra y Lora (Google Fonts)[/center]"
			},
			{
				"title": "Música y sonido",
				"body": "[center]Audio ambiental y efectos (SFX) sintetizados proceduralmente[/center]"
			},
			{
				"title": "Agradecimientos",
				"body": "[center]Materia: Diseño de interfaces de software\n\nPruebas de jugabilidad:\nJuan Ruales · Luisa Arteaga · Danilo Zamora\nStefany Portillo · Daniela Arias[/center]"
			}
		]

	return [
		{
			"title": LocaleManager.t("credits_dev_title"),
			"body": "[center]%s[/center]" % LocaleManager.t("credits_dev_body")
		},
		{
			"title": LocaleManager.t("credits_narrative_title"),
			"body": "[center]%s[/center]" % LocaleManager.t("credits_narrative_body")
		},
		{
			"title": LocaleManager.t("credits_visual_title"),
			"body": "[center]%s[/center]" % LocaleManager.t("credits_visual_body")
		},
		{
			"title": LocaleManager.t("credits_audio_title"),
			"body": "[center]%s[/center]" % LocaleManager.t("credits_audio_body")
		},
		{
			"title": LocaleManager.t("credits_thanks_title"),
			"body": "[center]%s[/center]" % LocaleManager.t("credits_thanks_body")
		}
	]


func _update_locale_texts() -> void:
	if LocaleManager == null:
		return

	skip_button.text = LocaleManager.t("skip_credits")
	main_menu_button.text = LocaleManager.t("main_menu")
	replay_ending_button.text = LocaleManager.t("replay_ending")
	quit_game_button.text = LocaleManager.t("quit_game")
	closing_title_label.text = LocaleManager.t("menu_title")
	closing_subtitle_label.text = LocaleManager.pick("Gracias por recorrer Aldeavieja.", "Thank you for journeying through Oldtown.")


func _on_language_changed(_new_lang: String) -> void:
	_update_locale_texts()
	if not _is_showing_final_card:
		var sections: Array[Dictionary] = _get_localized_credits_sections()
		if _current_section_index < sections.size():
			var section_data: Dictionary = sections[_current_section_index]
			section_title_label.text = str(section_data.get("title", ""))
			section_body_label.text = str(section_data.get("body", ""))


func _start_credits_sequence() -> void:
	_is_showing_final_card = false
	_current_section_index = 0
	final_card_container.hide()
	sequence_container.show()
	_play_current_section()


func _play_current_section() -> void:
	var sections: Array[Dictionary] = _get_localized_credits_sections()
	if _current_section_index >= sections.size():
		_show_final_card()
		return

	var section_data: Dictionary = sections[_current_section_index]
	var section_title: String = str(section_data.get("title", ""))
	var hold_duration: float = 6.0 if _current_section_index == sections.size() - 1 else 4.8

	section_title_label.text = section_title
	section_body_label.text = str(section_data.get("body", ""))

	section_title_label.modulate.a = 1.0
	section_body_label.modulate.a = 1.0

	sequence_container.visible = true
	sequence_container.modulate.a = 0.0

	if _sequence_tween != null and _sequence_tween.is_valid():
		_sequence_tween.kill()

	_sequence_tween = create_tween()
	_sequence_tween.set_parallel(false)

	# Paso 1: Fade-in
	_sequence_tween.tween_property(sequence_container, "modulate:a", 1.0, 0.8)

	# Paso 2: Permanencia visible con texto en pantalla
	_sequence_tween.tween_interval(hold_duration)

	# Paso 3: Fade-out
	_sequence_tween.tween_property(sequence_container, "modulate:a", 0.0, 0.7)

	# Paso 4: Pausa breve en blanco entre tarjetas
	_sequence_tween.tween_interval(0.35)

	# Paso 5: Avanzar a la siguiente sección
	_sequence_tween.tween_callback(_advance_section)


func _advance_section() -> void:
	_current_section_index += 1
	_play_current_section()


func _show_final_card() -> void:
	if _sequence_tween != null and _sequence_tween.is_valid():
		_sequence_tween.kill()

	_is_showing_final_card = true
	sequence_container.hide()
	final_card_container.modulate.a = 0.0
	final_card_container.show()

	var fade_in: Tween = create_tween()
	fade_in.tween_property(final_card_container, "modulate:a", 1.0, 0.7)


func _on_main_menu_button_pressed() -> void:
	WorldState.reset_state()
	get_tree().change_scene_to_file(MAIN_MENU_PATH)


func _on_replay_ending_button_pressed() -> void:
	get_tree().change_scene_to_file(ENDING_SCREEN_PATH)


func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
