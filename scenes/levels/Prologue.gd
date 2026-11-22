class_name Prologue
extends Node2D

const NEXT_LEVEL_PATH: String = "res://scenes/levels/Level1.tscn"

const PROLOGUE_PAGES: Array[String] = [
	"Hay lugares que parecen guardar algo más que calles y edificios. Aldeavieja siempre fue uno de ellos. Aquí las personas se conocen por sus historias, las ventanas conservan recuerdos y hasta los objetos parecen saber quiénes han pasado por sus vidas.",
	"Pero últimamente algo está cambiando. Una mujer ha olvidado el rostro de su hermana. Un niño ya no recuerda quién le enseñó a montar bicicleta. En algunas fotografías aparecen espacios vacíos donde antes había personas. Y lo más extraño es que nadie parece darse cuenta. Nadie, excepto tu abuelo.",
	"Entre sus herramientas has encontrado un cuaderno de páginas blancas. En su cubierta hay una frase escrita a mano: «Los recuerdos no desaparecen de golpe. Primero dejan de tener quién los recuerde». Al tocar sus páginas, una fina capa de cera dorada comienza a dibujar una escena..."
]

const GRANDFATHER_CLOSING_LINE: String = "Al desvanecerse las demás figuras sobre el papel, la voz de tu abuelo resuena con serenidad desde la puerta del taller:\n\n[i]«Si has podido verlos, todavía estamos a tiempo».[/i]"

const SILHOUETTE_CHOICES: Array[Dictionary] = [
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

var _is_player_near_table: bool = false
var _is_sequence_active: bool = false
var _current_page_index: int = 0
var _is_ready_to_transition: bool = false

@onready var player: Player = $Player
@onready var notebook_table: Area2D = $NotebookTable
@onready var examine_prompt: Node2D = $NotebookTable/ExaminePrompt

@onready var prologue_overlay: CanvasLayer = $PrologueOverlay
@onready var prologue_panel: PanelContainer = $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel
@onready var narrative_text_label: RichTextLabel = $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel/MarginContainer/VBoxContainer/NarrativeTextLabel
@onready var notebook_page_container: PanelContainer = $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel/MarginContainer/VBoxContainer/NotebookPageContainer
@onready var choices_container: VBoxContainer = $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel/MarginContainer/VBoxContainer/ChoicesContainer
@onready var continue_button: Button = $PrologueOverlay/Dimmer/CenterContainer/ProloguePanel/MarginContainer/VBoxContainer/ContinueButton

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
	if _current_page_index < PROLOGUE_PAGES.size():
		narrative_text_label.text = PROLOGUE_PAGES[_current_page_index]
		notebook_page_container.hide()
		choices_container.hide()
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


func _show_silhouette_choice_step() -> void:
	narrative_text_label.text = "Sobre el papel blanco emergen cuatro siluetas trazadas en cera dorada. ¿En cuál de ellas enfocas tu atención?"
	continue_button.hide()
	notebook_page_container.show()
	choices_container.show()

	for key: Variant in silhouette_nodes.keys():
		var card: Control = silhouette_nodes[key] as Control
		if card != null:
			card.modulate.a = 1.0

	for child: Node in choices_container.get_children():
		choices_container.remove_child(child)
		child.queue_free()

	for choice_data: Dictionary in SILHOUETTE_CHOICES:
		var button: Button = Button.new()
		button.text = str(choice_data.get("text", ""))
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_on_silhouette_selected.bind(choice_data))
		choices_container.add_child(button)

	prologue_panel.reset_size()


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
	narrative_text_label.text = GRANDFATHER_CLOSING_LINE
	_is_ready_to_transition = true
	continue_button.text = "Salir a Aldeavieja"
	continue_button.show()
	prologue_panel.reset_size()
