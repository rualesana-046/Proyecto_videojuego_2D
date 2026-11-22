class_name Prologue
extends Node2D

const NEXT_LEVEL_PATH: String = "res://scenes/levels/Level1.tscn"

const PROLOGUE_PAGES_ES: Array[String] = [
	"Hay lugares que parecen guardar algo más que calles y edificios. Aldeavieja siempre fue uno de ellos. Aquí las personas se conocen por sus historias, las ventanas conservan recuerdos y hasta los objetos parecen saber quiénes han pasado por sus vidas.",
	"Pero últimamente algo está cambiando. Una mujer ha olvidado el rostro de su hermana. Un niño ya no recuerda quién le enseñó a montar bicicleta. En algunas fotografías aparecen espacios vacíos donde antes había personas. Y lo más extraño es que nadie parece darse cuenta. Nadie, excepto tu abuelo.",
	"Entre sus herramientas has encontrado un cuaderno de páginas blancas. En su cubierta hay una frase escrita a mano: «Los recuerdos no desaparecen de golpe. Primero dejan de tener quién los recuerde». Al tocar sus páginas, una fina capa de cera dorada comienza a dibujar una escena..."
]

const PROLOGUE_PAGES_EN: Array[String] = [
	"There are places that seem to shelter far more than streets and buildings. Aldeavieja was always one of them. Here, people know each other by their stories, windows harbor memories, and even everyday objects seem to know whose lives have brushed against them.",
	"Yet lately, something has begun to change. A woman has forgotten the face of her sister. A child no longer remembers who taught him to ride a bicycle. In photographs, vacant spaces appear where loved ones once stood. And strangest of all, no one seems to notice. No one, except your grandfather.",
	"Among his tools, you found a notebook filled with blank pages. On its leather cover, a handwritten inscription reads: «Memories do not vanish all at once. First, they simply run out of someone to remember them». As your fingers touch its pages, a delicate layer of golden wax begins sketching a scene..."
]

const GRANDFATHER_CLOSING_LINE_ES: String = "Al desvanecerse las demás figuras sobre el papel, la voz de tu abuelo resuena con serenidad desde la puerta del taller:\n\n[i]«Si has podido verlos, todavía estamos a tiempo».[/i]"
const GRANDFATHER_CLOSING_LINE_EN: String = "As the other figures dissolve softly into the paper, your grandfather's voice echoes with serene warmth from the workshop doorway:\n\n[i]«If you were able to see them, there is still time».[/i]"

var _is_player_near_table: bool = false
var _is_sequence_active: bool = false
var _current_page_index: int = 0
var _is_ready_to_transition: bool = false

@onready var player: Player = $Player
@onready var notebook_table: Area2D = $NotebookTable
@onready var examine_prompt: Node2D = $NotebookTable/ExaminePrompt
@onready var examine_prompt_label: Label = $NotebookTable/ExaminePrompt/PromptPanel/PromptLabel

@onready var prologue_overlay: CanvasLayer = $PrologueOverlay
@onready var prologue_panel: PanelContainer = $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel
@onready var prologue_title_label: Label = $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel/MarginContainer/VBoxContainer/TitleLabel
@onready var narrative_text_label: RichTextLabel = $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel/MarginContainer/VBoxContainer/NarrativeTextLabel
@onready var notebook_page_container: PanelContainer = $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel/MarginContainer/VBoxContainer/NotebookPageContainer
@onready var choices_container: VBoxContainer = $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel/MarginContainer/VBoxContainer/ChoicesContainer
@onready var continue_button: Button = $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel/MarginContainer/VBoxContainer/ContinueButton

@onready var caption_girl: Label = $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel/MarginContainer/VBoxContainer/NotebookPageContainer/SilhouettesRow/SilhouetteGirl/Caption
@onready var caption_elder: Label = $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel/MarginContainer/VBoxContainer/NotebookPageContainer/SilhouettesRow/SilhouetteElder/Caption
@onready var caption_distant: Label = $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel/MarginContainer/VBoxContainer/NotebookPageContainer/SilhouettesRow/SilhouetteDistant/Caption
@onready var caption_self: Label = $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel/MarginContainer/VBoxContainer/NotebookPageContainer/SilhouettesRow/SilhouetteSelf/Caption

@onready var silhouette_nodes: Dictionary = {
	"girl": $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel/MarginContainer/VBoxContainer/NotebookPageContainer/SilhouettesRow/SilhouetteGirl,
	"elder": $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel/MarginContainer/VBoxContainer/NotebookPageContainer/SilhouettesRow/SilhouetteElder,
	"distant": $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel/MarginContainer/VBoxContainer/NotebookPageContainer/SilhouettesRow/SilhouetteDistant,
	"self": $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel/MarginContainer/VBoxContainer/NotebookPageContainer/SilhouettesRow/SilhouetteSelf
}


func _ready() -> void:
	WorldState.current_level = "res://scenes/levels/Prologue.tscn"
	prologue_overlay.hide()
	examine_prompt.hide()

	notebook_table.body_entered.connect(_on_notebook_table_body_entered)
	notebook_table.body_exited.connect(_on_notebook_table_body_exited)
	continue_button.pressed.connect(_on_continue_button_pressed)

	if LocaleManager != null:
		LocaleManager.language_changed.connect(_on_language_changed)

	_update_locale_texts()


func _update_locale_texts() -> void:
	if examine_prompt_label != null:
		examine_prompt_label.text = LocaleManager.pick("[E] Examinar cuaderno", "[E] Examine notebook") if LocaleManager != null else "[E] Examinar cuaderno"

	if prologue_title_label != null:
		prologue_title_label.text = LocaleManager.pick("PRÓLOGO", "PROLOGUE") if LocaleManager != null else "PRÓLOGO"

	if caption_girl != null:
		caption_girl.text = LocaleManager.pick("La niña", "The girl") if LocaleManager != null else "La niña"
	if caption_elder != null:
		caption_elder.text = LocaleManager.pick("El anciano", "The old man") if LocaleManager != null else "El anciano"
	if caption_distant != null:
		caption_distant.text = LocaleManager.pick("La 3.ª figura", "The 3rd figure") if LocaleManager != null else "La 3.ª figura"
	if caption_self != null:
		caption_self.text = LocaleManager.pick("Tu silueta", "Your silhouette") if LocaleManager != null else "Tu silueta"

	if _is_ready_to_transition:
		continue_button.text = LocaleManager.pick("Salir a Aldeavieja", "Step out into Aldeavieja") if LocaleManager != null else "Salir a Aldeavieja"
		narrative_text_label.text = GRANDFATHER_CLOSING_LINE_EN if LocaleManager != null and LocaleManager.current_lang == "en" else GRANDFATHER_CLOSING_LINE_ES
	elif _is_sequence_active:
		var pages: Array[String] = PROLOGUE_PAGES_EN if LocaleManager != null and LocaleManager.current_lang == "en" else PROLOGUE_PAGES_ES
		if _current_page_index < pages.size():
			narrative_text_label.text = pages[_current_page_index]
			continue_button.text = LocaleManager.pick("Continuar", "Continue") if LocaleManager != null else "Continuar"
		else:
			narrative_text_label.text = LocaleManager.pick(
				"Sobre el papel blanco emergen cuatro siluetas trazadas en cera dorada. ¿En cuál de ellas enfocas tu atención?",
				"Across the blank paper, four silhouettes emerge traced in golden wax. Which of them draws your focus?"
			) if LocaleManager != null else "Sobre el papel blanco emergen cuatro siluetas trazadas en cera dorada. ¿En cuál de ellas enfocas tu atención?"
			_populate_silhouette_choice_buttons()
	else:
		if continue_button != null:
			continue_button.text = LocaleManager.pick("Continuar", "Continue") if LocaleManager != null else "Continuar"


func _on_language_changed(_new_lang: String) -> void:
	_update_locale_texts()


func _unhandled_input(event: InputEvent) -> void:
	if _is_sequence_active or not _is_player_near_table:
		return

	var is_interact: bool = (
		event.is_action_pressed("interact")
		or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	)
	if is_interact:
		_start_prologue_sequence()
		get_viewport().set_input_as_handled()


func _on_notebook_table_body_entered(body: Node2D) -> void:
	if body is Player:
		_is_player_near_table = true
		if not _is_sequence_active:
			examine_prompt.show()


func _on_notebook_table_body_exited(body: Node2D) -> void:
	if body is Player:
		_is_player_near_table = false
		examine_prompt.hide()


func _start_prologue_sequence() -> void:
	_is_sequence_active = true
	_current_page_index = 0
	_is_ready_to_transition = false
	examine_prompt.hide()

	if is_instance_valid(player):
		player.velocity = Vector2.ZERO
		player.set_physics_process(false)

	if not WorldState.known_characters.has("Abuelo (Maestro Encuadernador)"):
		WorldState.known_characters.append("Abuelo (Maestro Encuadernador)")
	if not WorldState.recovered_memories.has("El hallazgo del Cuaderno de Cera en el taller del abuelo"):
		WorldState.recovered_memories.append("El hallazgo del Cuaderno de Cera en el taller del abuelo")
	WorldState.exploration_score += 1

	prologue_overlay.show()
	_show_current_page()


func _show_current_page() -> void:
	var pages: Array[String] = PROLOGUE_PAGES_EN if LocaleManager != null and LocaleManager.current_lang == "en" else PROLOGUE_PAGES_ES
	if _current_page_index < pages.size():
		narrative_text_label.text = pages[_current_page_index]
		notebook_page_container.hide()
		choices_container.hide()
		continue_button.text = LocaleManager.pick("Continuar", "Continue") if LocaleManager != null else "Continuar"
		continue_button.show()
		prologue_panel.reset_size()
	else:
		_show_silhouette_choice_step()


func _on_continue_button_pressed() -> void:
	if _is_ready_to_transition:
		WorldState.current_level = NEXT_LEVEL_PATH
		get_tree().change_scene_to_file(NEXT_LEVEL_PATH)
		return

	_current_page_index += 1
	_show_current_page()


func _get_silhouette_choices() -> Array[Dictionary]:
	var is_en: bool = LocaleManager != null and LocaleManager.current_lang == "en"
	if is_en:
		return [
			{
				"id": "girl",
				"text": "The young girl: she seems to be searching for someone.",
				"trait": "nostalgia",
				"amount": 1,
				"journal_text": "In the Wax Notebook, you observed the silhouette of the young girl searching for someone."
			},
			{
				"id": "elder",
				"text": "The old man: he holds an object that feels familiar to him.",
				"trait": "curiosity",
				"amount": 1,
				"journal_text": "In the Wax Notebook, you observed the silhouette of the old man holding a familiar object."
			},
			{
				"id": "distant",
				"text": "The third figure: a distant silhouette watching in silence.",
				"trait": "curiosity",
				"amount": 1,
				"journal_text": "In the Wax Notebook, you observed the distant third figure watching in silence."
			},
			{
				"id": "self",
				"text": "Choose myself: observe your own silhouette.",
				"trait": "pragmatism",
				"amount": 1,
				"journal_text": "In the Wax Notebook, you chose to observe your own silhouette before departing."
			}
		]

	return [
		{
			"id": "girl",
			"text": "La niña: parece estar buscando a alguien.",
			"trait": "nostalgia",
			"amount": 1,
			"journal_text": "En el Cuaderno de Cera observaste la silueta de la niña que buscaba a alguien."
		},
		{
			"id": "elder",
			"text": "El anciano: sostiene un objeto que parece reconocer.",
			"trait": "curiosity",
			"amount": 1,
			"journal_text": "En el Cuaderno de Cera observaste la silueta del anciano que sostenía un objeto familiar."
		},
		{
			"id": "distant",
			"text": "La tercera figura: una silueta distante que observa en silencio.",
			"trait": "curiosity",
			"amount": 1,
			"journal_text": "En el Cuaderno de Cera observaste la tercera figura distante que vigilaba en silencio."
		},
		{
			"id": "self",
			"text": "Elegirme a mí: observar tu propia silueta.",
			"trait": "pragmatism",
			"amount": 1,
			"journal_text": "En el Cuaderno de Cera decidiste observar tu propia silueta antes de partir."
		}
	]


func _show_silhouette_choice_step() -> void:
	narrative_text_label.text = LocaleManager.pick(
		"Sobre el papel blanco emergen cuatro siluetas trazadas en cera dorada. ¿En cuál de ellas enfocas tu atención?",
		"Across the blank paper, four silhouettes emerge traced in golden wax. Which of them draws your focus?"
	) if LocaleManager != null else "Sobre el papel blanco emergen cuatro siluetas trazadas en cera dorada. ¿En cuál de ellas enfocas tu atención?"

	continue_button.hide()
	notebook_page_container.show()
	choices_container.show()

	for key: Variant in silhouette_nodes.keys():
		var card: Control = silhouette_nodes[key] as Control
		if card != null:
			card.modulate.a = 1.0

	_populate_silhouette_choice_buttons()
	prologue_panel.reset_size()


func _populate_silhouette_choice_buttons() -> void:
	for child: Node in choices_container.get_children():
		choices_container.remove_child(child)
		child.queue_free()

	for choice_data: Dictionary in _get_silhouette_choices():
		var button: Button = Button.new()
		button.text = str(choice_data.get("text", ""))
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_on_silhouette_selected.bind(choice_data))
		button.pressed.connect(AudioManager.play_ui_click)
		choices_container.add_child(button)


func _on_silhouette_selected(choice_data: Dictionary) -> void:
	var chosen_id: String = str(choice_data.get("id", "self"))
	var trait_name: String = str(choice_data.get("trait", "nostalgia"))
	var amount: int = int(choice_data.get("amount", 1))
	var journal_text: String = str(choice_data.get("journal_text", ""))

	AIProfiler.add_points(trait_name, amount)
	WorldState.important_choices["prologue_silhouette"] = journal_text
	WorldState.narrative_profile = AIProfiler.get_dominant_profile()

	choices_container.hide()
	prologue_panel.reset_size()

	var fade_tween: Tween = create_tween().set_parallel(true)
	for key: Variant in silhouette_nodes.keys():
		var silhouette_id: String = str(key)
		var card: Control = silhouette_nodes[silhouette_id] as Control
		if card == null:
			continue

		if silhouette_id != chosen_id:
			fade_tween.tween_property(card, "modulate:a", 0.0, 1.2)
		else:
			fade_tween.tween_property(card, "modulate:a", 1.0, 1.2)

	fade_tween.chain().tween_callback(_on_silhouettes_fade_completed)


func _on_silhouettes_fade_completed() -> void:
	narrative_text_label.text = GRANDFATHER_CLOSING_LINE_EN if LocaleManager != null and LocaleManager.current_lang == "en" else GRANDFATHER_CLOSING_LINE_ES
	_is_ready_to_transition = true
	continue_button.text = LocaleManager.pick("Salir a Aldeavieja", "Step out into Aldeavieja") if LocaleManager != null else "Salir a Aldeavieja"
	continue_button.show()
	prologue_panel.reset_size()
