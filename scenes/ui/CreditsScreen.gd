class_name CreditsScreen
extends Control

const MAIN_MENU_PATH: String = "res://scenes/ui/MainMenu.tscn"
const ENDING_SCREEN_PATH: String = "res://scenes/ui/EndingScreen.tscn"

const CREDITS_SECTIONS: Array[Dictionary] = [
	{
		"title": "Desarrollo",
		"body": "[center]Programación y Arquitectura en Godot 4 (GDScript)\nSistemas de estado persistente (WorldState), perfilador narrativo adaptativo (AIProfiler)\ny mecánicas de exploración, persecución y reconstrucción de recuerdos.[/center]"
	},
	{
		"title": "Diseño narrativo",
		"body": "[center]Historia original, guion ramificado y construcción de mundo de\n[i]«El Guardián de las Páginas en Blanco: Crónicas de Aldeavieja»[/i]\nPersonajes: Lucía, Tomás, Don Elías, Marta, Inés, Samuel, Elena y el Abuelo.[/center]"
	},
	{
		"title": "Diseño visual",
		"body": "[center]Dirección de arte cálida desaturada y portada ilustrada al atardecer\nSprites y tilesets pixel-art 16×16, siluetas en tinta sepia y cera dorada\nTipografía literaria Almendra & Lora y marcos ornamentales en verde esmeralda y dorado champán.[/center]"
	},
	{
		"title": "Música y sonido",
		"body": "[center]Paisaje sonoro ambiental y arquitectura de buses de audio\n(Volumen General, Música y Efectos)\nAtmósferas de lluvia en el taller, campanas de estación y brisa de atardecer.[/center]"
	},
	{
		"title": "Agradecimientos",
		"body": "[center]A quienes conservan fotografías antiguas, doblan flores de papel\ny mantienen vivas las historias compartidas de su comunidad.\n\nY especialmente a ti, por acompañar al Guardián hasta la última página.[/center]"
	}
]

var _sequence_tween: Tween = null
var _current_section_index: int = 0
var _is_showing_final_card: bool = false

@onready var sequence_container: VBoxContainer = $CreditsPanel/MarginContainer/SequenceContainer
@onready var section_title_label: Label = $CreditsPanel/MarginContainer/SequenceContainer/SectionTitleLabel
@onready var section_body_label: RichTextLabel = $CreditsPanel/MarginContainer/SequenceContainer/SectionBodyLabel
@onready var skip_button: Button = $CreditsPanel/MarginContainer/SequenceContainer/SkipButton

@onready var final_card_container: VBoxContainer = $CreditsPanel/MarginContainer/FinalCardContainer
@onready var main_menu_button: Button = $CreditsPanel/MarginContainer/FinalCardContainer/MainMenuButton
@onready var replay_ending_button: Button = $CreditsPanel/MarginContainer/FinalCardContainer/ReplayEndingButton
@onready var quit_game_button: Button = $CreditsPanel/MarginContainer/FinalCardContainer/QuitGameButton


func _ready() -> void:
	skip_button.pressed.connect(_show_final_card)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	replay_ending_button.pressed.connect(_on_replay_ending_button_pressed)
	quit_game_button.pressed.connect(_on_quit_game_button_pressed)

	_start_credits_sequence()


func _unhandled_input(event: InputEvent) -> void:
	if _is_showing_final_card:
		return

	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_show_final_card()
		get_viewport().set_input_as_handled()


func _start_credits_sequence() -> void:
	_is_showing_final_card = false
	_current_section_index = 0
	final_card_container.hide()
	sequence_container.show()
	_play_current_section()


func _play_current_section() -> void:
	if _current_section_index >= CREDITS_SECTIONS.size():
		_show_final_card()
		return

	var section_data: Dictionary = CREDITS_SECTIONS[_current_section_index]
	section_title_label.text = str(section_data.get("title", ""))
	section_body_label.text = str(section_data.get("body", ""))

	section_title_label.modulate.a = 0.0
	section_body_label.modulate.a = 0.0

	if _sequence_tween != null and _sequence_tween.is_valid():
		_sequence_tween.kill()

	_sequence_tween = create_tween()
	_sequence_tween.set_parallel(true)
	_sequence_tween.tween_property(section_title_label, "modulate:a", 1.0, 0.7)
	_sequence_tween.tween_property(section_body_label, "modulate:a", 1.0, 0.7)
	_sequence_tween.chain().tween_interval(2.6)
	_sequence_tween.set_parallel(true)
	_sequence_tween.tween_property(section_title_label, "modulate:a", 0.0, 0.5)
	_sequence_tween.tween_property(section_body_label, "modulate:a", 0.0, 0.5)
	_sequence_tween.chain().tween_callback(_advance_section)


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
