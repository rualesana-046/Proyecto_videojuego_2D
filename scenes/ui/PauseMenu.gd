class_name PauseMenu
extends CanvasLayer

const MAIN_MENU_PATH: String = "res://scenes/ui/MainMenu.tscn"
const MASTER_BUS_NAME: String = "Master"
const MUSIC_BUS_NAME: String = "Music"
const SFX_BUS_NAME: String = "SFX"

const CHOICE_LABELS: Dictionary = {
	"prologue_silhouette": "Visión en el taller del abuelo",
	"lucia_tomas_reconstruction": "Reconstrucción del recuerdo de Lucía",
	"samuel_memory_focus": "Reflexión junto al recuerdo de Samuel",
	"level2_distractions_used": "Tácticas en la antigua estación",
	"study_investigation_focus": "Investigación en el estudio del abuelo",
	"final_decision": "Decisión frente a La Memoria Compartida"
}

const CHOICE_LABELS_EN: Dictionary = {
	"prologue_silhouette": "Vision in grandfather's workshop",
	"lucia_tomas_reconstruction": "Lucía's memory reconstruction",
	"samuel_memory_focus": "Reflection by Samuel's memory",
	"level2_distractions_used": "Tactics in the old station",
	"study_investigation_focus": "Investigation in grandfather's study",
	"final_decision": "Decision before the Shared Memory"
}

const CLUE_LABELS: Dictionary = {
	"clue_photo": "Fotografía antigua junto a la panadería (Lucía y la silueta de una bicicleta)",
	"clue_paper_flower": "Flor de papel doblada entregada por Marta (encargo de Tomás)",
	"clue_bridge": "Inscripción en el antiguo puente («Aquí aprendimos a no tener miedo de caer»)",
	"llave_estacion": "Llave antigua de la estación entregada por Inés",
	"clue_samuel_photo": "Fotografía de Samuel y el abuelo en el pasillo de mantenimiento",
	"carta_abuelo": "Carta del abuelo hallada en la caja metálica de la Torre del Reloj",
	"item_dried_flower": "Flor seca conservada en el jardín de la casa familiar",
	"item_photo": "Fotografía del abuelo junto a Elena en la sala principal",
	"item_letter": "Carta inconclusa hallada en el estudio de encuadernación",
	"item_ribbon": "Cinta de encuadernación hallada en el estudio",
	"item_last_letter": "Última carta guardada en la habitación del abuelo"
}

const CLUE_LABELS_EN: Dictionary = {
	"clue_photo": "Old photograph by the bakery (Lucía and the silhouette of a bicycle)",
	"clue_paper_flower": "Folded paper flower given by Marta (on behalf of Tomás)",
	"clue_bridge": "Inscription on the old bridge ('Here we learned not to fear falling')",
	"llave_estacion": "Old station key given by Inés",
	"clue_samuel_photo": "Photograph of Samuel and grandfather in the maintenance hallway",
	"carta_abuelo": "Grandfather's letter found in the Clock Tower metal box",
	"item_dried_flower": "Dried flower preserved in the family house garden",
	"item_photo": "Photograph of grandfather with Elena in the main hall",
	"item_letter": "Unfinished letter found in the bookbinding study",
	"item_ribbon": "Binding ribbon found in the study",
	"item_last_letter": "Last letter kept in grandfather's bedroom"
}

const MEMORY_LABELS_EN: Dictionary = {
	"El hallazgo del Cuaderno de Cera en el taller del abuelo": "The discovery of the Wax Notebook in grandfather's workshop",
	"Recuerdo de Lucía y Tomás (Completo)": "Lucía and Tomás's Memory (Complete)",
	"Recuerdo de Lucía y Tomás (Parcial)": "Lucía and Tomás's Memory (Partial)",
	"Recuerdo de Samuel en el andén": "Samuel's Memory on the platform",
	"Carta del abuelo en la torre del reloj": "Grandfather's Letter in the clock tower",
	"Página adicional: Los viajes del abuelo y Samuel en la estación": "Bonus page: Grandfather and Samuel's journeys at the station",
	"El primer encuentro (Abuelo y Elena)": "The First Meeting (Grandfather and Elena)",
	"La promesa del estudio": "The Study's Promise",
	"La despedida de Elena": "Elena's Farewell"
}

var _save_feedback_tween: Tween = null
var _open_tween: Tween = null

@onready var main_pause_panel: PanelContainer = $Overlay/MainPausePanel
@onready var pause_main_title: Label = $Overlay/MainPausePanel/MarginContainer/VBoxContainer/TitleLabel
@onready var current_location_label: Label = $Overlay/MainPausePanel/MarginContainer/VBoxContainer/CurrentLocationLabel
@onready var save_feedback_label: Label = $Overlay/MainPausePanel/MarginContainer/VBoxContainer/SaveFeedbackLabel
@onready var resume_button: Button = $Overlay/MainPausePanel/MarginContainer/VBoxContainer/ResumeButton
@onready var save_button: Button = $Overlay/MainPausePanel/MarginContainer/VBoxContainer/SaveButton
@onready var journal_button: Button = $Overlay/MainPausePanel/MarginContainer/VBoxContainer/JournalButton
@onready var options_button: Button = $Overlay/MainPausePanel/MarginContainer/VBoxContainer/OptionsButton
@onready var main_menu_button: Button = $Overlay/MainPausePanel/MarginContainer/VBoxContainer/MainMenuButton
@onready var quit_game_button: Button = $Overlay/MainPausePanel/MarginContainer/VBoxContainer/QuitGameButton
@onready var pause_footer_label: Label = $Overlay/MainPausePanel/MarginContainer/VBoxContainer/PauseFooterLabel

@onready var journal_panel: PanelContainer = $Overlay/JournalPanel
@onready var journal_content_label: RichTextLabel = $Overlay/JournalPanel/MarginContainer/VBoxContainer/ScrollContainer/JournalContentLabel
@onready var close_journal_button: Button = $Overlay/JournalPanel/MarginContainer/VBoxContainer/CloseJournalButton

@onready var options_panel: PanelContainer = $Overlay/OptionsPanel
@onready var options_title_label: Label = $Overlay/OptionsPanel/MarginContainer/VBoxContainer/OptionsTitleLabel
@onready var master_label: Label = $Overlay/OptionsPanel/MarginContainer/VBoxContainer/MasterRow/MasterLabel
@onready var master_slider: HSlider = $Overlay/OptionsPanel/MarginContainer/VBoxContainer/MasterRow/MasterSlider
@onready var music_label: Label = $Overlay/OptionsPanel/MarginContainer/VBoxContainer/MusicRow/MusicLabel
@onready var music_slider: HSlider = $Overlay/OptionsPanel/MarginContainer/VBoxContainer/MusicRow/MusicSlider
@onready var sfx_label: Label = $Overlay/OptionsPanel/MarginContainer/VBoxContainer/SfxRow/SfxLabel
@onready var sfx_slider: HSlider = $Overlay/OptionsPanel/MarginContainer/VBoxContainer/SfxRow/SfxSlider
@onready var language_label: Label = $Overlay/OptionsPanel/MarginContainer/VBoxContainer/LanguageRow/LanguageLabel
@onready var language_button: Button = $Overlay/OptionsPanel/MarginContainer/VBoxContainer/LanguageRow/LanguageButton
@onready var fullscreen_check_button: CheckButton = $Overlay/OptionsPanel/MarginContainer/VBoxContainer/FullscreenCheckButton
@onready var tutorial_button: Button = $Overlay/OptionsPanel/MarginContainer/VBoxContainer/TutorialButton
@onready var close_options_button: Button = $Overlay/OptionsPanel/MarginContainer/VBoxContainer/CloseOptionsButton

@onready var tutorial_panel: PanelContainer = $Overlay/TutorialPanel
@onready var tutorial_title_label: Label = $Overlay/TutorialPanel/MarginContainer/VBoxContainer/TutorialTitleLabel
@onready var tutorial_content_label: RichTextLabel = $Overlay/TutorialPanel/MarginContainer/VBoxContainer/ScrollContainer/TutorialContentLabel
@onready var close_tutorial_button: Button = $Overlay/TutorialPanel/MarginContainer/VBoxContainer/CloseTutorialButton

@onready var confirm_main_menu_panel: PanelContainer = $Overlay/ConfirmMainMenuPanel
@onready var confirm_main_menu_label: Label = $Overlay/ConfirmMainMenuPanel/MarginContainer/VBoxContainer/ConfirmMainMenuLabel
@onready var confirm_main_menu_yes_button: Button = $Overlay/ConfirmMainMenuPanel/MarginContainer/VBoxContainer/ConfirmMainMenuYesButton
@onready var confirm_main_menu_no_button: Button = $Overlay/ConfirmMainMenuPanel/MarginContainer/VBoxContainer/ConfirmMainMenuNoButton

@onready var confirm_quit_panel: PanelContainer = $Overlay/ConfirmQuitPanel
@onready var confirm_quit_label: Label = $Overlay/ConfirmQuitPanel/MarginContainer/VBoxContainer/ConfirmQuitLabel
@onready var confirm_quit_yes_button: Button = $Overlay/ConfirmQuitPanel/MarginContainer/VBoxContainer/ConfirmQuitYesButton
@onready var confirm_quit_no_button: Button = $Overlay/ConfirmQuitPanel/MarginContainer/VBoxContainer/ConfirmQuitNoButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_audio_buses()
	_sync_options_controls()
	hide()

	resume_button.pressed.connect(_on_resume_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	journal_button.pressed.connect(_on_journal_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	quit_game_button.pressed.connect(_on_quit_game_button_pressed)
	language_button.pressed.connect(_on_language_button_pressed)

	for btn: Button in [
		resume_button,
		save_button,
		journal_button,
		options_button,
		language_button,
		main_menu_button,
		quit_game_button,
		close_journal_button,
		tutorial_button,
		close_tutorial_button,
		close_options_button,
		confirm_main_menu_yes_button,
		confirm_main_menu_no_button,
		confirm_quit_yes_button,
		confirm_quit_no_button
	]:
		btn.pressed.connect(AudioManager.play_ui_click)

	close_journal_button.pressed.connect(_show_main_pause_panel)
	tutorial_button.pressed.connect(_on_tutorial_button_pressed)
	close_tutorial_button.pressed.connect(_on_close_tutorial_button_pressed)
	close_options_button.pressed.connect(_show_main_pause_panel)

	master_slider.value_changed.connect(_on_bus_volume_changed.bind(MASTER_BUS_NAME))
	music_slider.value_changed.connect(_on_bus_volume_changed.bind(MUSIC_BUS_NAME))
	sfx_slider.value_changed.connect(_on_bus_volume_changed.bind(SFX_BUS_NAME))
	fullscreen_check_button.toggled.connect(_on_fullscreen_toggled)

	confirm_main_menu_yes_button.pressed.connect(_on_confirm_main_menu_yes_pressed)
	confirm_main_menu_no_button.pressed.connect(_show_main_pause_panel)

	confirm_quit_yes_button.pressed.connect(_on_confirm_quit_yes_pressed)
	confirm_quit_no_button.pressed.connect(_show_main_pause_panel)

	if LocaleManager != null:
		LocaleManager.language_changed.connect(_on_language_changed)

	_update_locale_texts()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible and tutorial_panel.visible:
			_on_close_tutorial_button_pressed()
			get_viewport().set_input_as_handled()
			return

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
		_refresh_pause_metadata()
		_show_main_pause_panel()
		_play_open_animation()


func _refresh_pause_metadata() -> void:
	current_location_label.text = _resolve_current_location_name()
	var footer_format: String = LocaleManager.pick("Cera: %d · Recuerdos: %d", "Wax: %d · Memories: %d") if LocaleManager != null else "Cera: %d · Recuerdos: %d"
	pause_footer_label.text = footer_format % [
		WorldState.wax_remaining,
		WorldState.recovered_memories.size()
	]


func _resolve_current_location_name() -> String:
	var scene_path: String = WorldState.current_level
	if get_tree().current_scene != null and not get_tree().current_scene.scene_file_path.is_empty():
		scene_path = get_tree().current_scene.scene_file_path

	if scene_path.contains("Prologue"):
		return LocaleManager.pick("Prólogo · Taller del Abuelo", "Prologue · Grandfather's Workshop") if LocaleManager != null else "Prólogo · Taller del Abuelo"
	if scene_path.contains("Level1"):
		return LocaleManager.pick("Nivel 1 · La Plaza de Aldeavieja", "Level 1 · Oldtown Plaza") if LocaleManager != null else "Nivel 1 · La Plaza de Aldeavieja"
	if scene_path.contains("Level2"):
		return LocaleManager.pick("Nivel 2 · La Antigua Estación", "Level 2 · The Old Station") if LocaleManager != null else "Nivel 2 · La Antigua Estación"
	if scene_path.contains("Level3"):
		return LocaleManager.pick("Nivel 3 · La Casa de los Recuerdos", "Level 3 · The House of Memories") if LocaleManager != null else "Nivel 3 · La Casa de los Recuerdos"

	return LocaleManager.pick("Aldeavieja", "Oldtown") if LocaleManager != null else "Aldeavieja"


func _on_language_button_pressed() -> void:
	if LocaleManager != null:
		LocaleManager.toggle_language()


func _on_language_changed(_new_lang: String) -> void:
	_update_locale_texts()
	_refresh_pause_metadata()
	if journal_panel != null and journal_panel.visible:
		_populate_journal()


func _update_locale_texts() -> void:
	if LocaleManager == null:
		return

	pause_main_title.text = LocaleManager.pick("En pausa", "Paused")
	resume_button.text = LocaleManager.t("resume")
	save_button.text = LocaleManager.t("save_game")
	journal_button.text = LocaleManager.t("journal")
	options_button.text = LocaleManager.t("options")
	main_menu_button.text = LocaleManager.t("main_menu")
	quit_game_button.text = LocaleManager.t("quit_game")

	options_title_label.text = LocaleManager.t("options_title")
	master_label.text = LocaleManager.t("master_volume")
	music_label.text = LocaleManager.t("music_volume")
	sfx_label.text = LocaleManager.t("sfx_volume")
	language_label.text = LocaleManager.t("language_label")
	language_button.text = LocaleManager.t("language_button")
	fullscreen_check_button.text = LocaleManager.t("fullscreen")
	tutorial_button.text = LocaleManager.t("how_to_play")
	close_options_button.text = LocaleManager.t("back")
	close_journal_button.text = LocaleManager.t("back")

	tutorial_title_label.text = LocaleManager.t("tutorial_title")
	tutorial_content_label.text = LocaleManager.t("tutorial_content")
	close_tutorial_button.text = LocaleManager.t("back")

	confirm_main_menu_label.text = LocaleManager.pick(
		"¿Estás seguro de que deseas volver al menú principal? Se perderá el progreso no guardado.",
		"Are you sure you want to return to the main menu? Unsaved progress will be lost."
	)
	confirm_main_menu_yes_button.text = LocaleManager.t("yes")
	confirm_main_menu_no_button.text = LocaleManager.t("no")

	confirm_quit_label.text = LocaleManager.pick(
		"¿Estás seguro de que deseas salir del juego? Se perderá el progreso no guardado.",
		"Are you sure you want to exit the game? Unsaved progress will be lost."
	)
	confirm_quit_yes_button.text = LocaleManager.t("yes")
	confirm_quit_no_button.text = LocaleManager.t("no")


func _play_open_animation() -> void:
	if _open_tween != null and _open_tween.is_valid():
		_open_tween.kill()

	main_pause_panel.modulate.a = 0.0
	main_pause_panel.scale = Vector2(0.96, 0.96)
	main_pause_panel.pivot_offset = main_pause_panel.size * 0.5

	_open_tween = create_tween()
	_open_tween.set_parallel(true)
	_open_tween.tween_property(main_pause_panel, "modulate:a", 1.0, 0.18)
	_open_tween.tween_property(main_pause_panel, "scale", Vector2.ONE, 0.18)


func _show_main_pause_panel() -> void:
	journal_panel.hide()
	options_panel.hide()
	tutorial_panel.hide()
	confirm_main_menu_panel.hide()
	confirm_quit_panel.hide()
	main_pause_panel.show()


func _is_any_subpanel_open() -> bool:
	return (
		journal_panel.visible
		or options_panel.visible
		or tutorial_panel.visible
		or confirm_main_menu_panel.visible
		or confirm_quit_panel.visible
	)


func _on_resume_button_pressed() -> void:
	toggle_pause()


func _on_save_button_pressed() -> void:
	if WorldState.save_game():
		_show_save_feedback(LocaleManager.t("saved_feedback") if LocaleManager != null else "¡Partida guardada!")
	else:
		_show_save_feedback(LocaleManager.pick("Error al guardar partida.", "Error saving game.") if LocaleManager != null else "Error al guardar partida.")


func _show_save_feedback(message: String) -> void:
	if _save_feedback_tween != null and _save_feedback_tween.is_valid():
		_save_feedback_tween.kill()

	save_feedback_label.text = message
	save_feedback_label.modulate.a = 0.0
	save_feedback_label.show()

	_save_feedback_tween = create_tween()
	_save_feedback_tween.tween_property(save_feedback_label, "modulate:a", 1.0, 0.25)
	_save_feedback_tween.tween_interval(1.8)
	_save_feedback_tween.tween_property(save_feedback_label, "modulate:a", 0.0, 0.4)
	_save_feedback_tween.tween_callback(save_feedback_label.hide)


func _on_journal_button_pressed() -> void:
	_populate_journal()
	main_pause_panel.hide()
	journal_panel.show()


func _populate_journal() -> void:
	var lines: PackedStringArray = PackedStringArray()
	var is_en: bool = LocaleManager != null and LocaleManager.current_lang == "en"

	# --- Páginas y Recuerdos Recuperados ---
	lines.append("[b][color=#C9AE7C]— %s —[/color][/b]" % (
		LocaleManager.pick("Páginas y Recuerdos Recuperados", "Pages & Recovered Memories")
		if LocaleManager != null else "Páginas y Recuerdos Recuperados"
	))
	if WorldState.recovered_memories.is_empty():
		lines.append(
			LocaleManager.pick(
				"[i]Aún no has recuperado páginas completas en el cuaderno.[/i]",
				"[i]You have not yet recovered complete pages in the notebook.[/i]"
			) if LocaleManager != null else "[i]Aún no has recuperado páginas completas en el cuaderno.[/i]"
		)
	else:
		for mem: String in WorldState.recovered_memories:
			var mem_label: String = str(MEMORY_LABELS_EN.get(mem, mem)) if is_en else mem
			lines.append("• " + mem_label)

	# --- Pistas y Objetos Descubiertos ---
	lines.append("\n[b][color=#C9AE7C]— %s —[/color][/b]" % (
		LocaleManager.pick("Pistas y Objetos Descubiertos", "Clues & Discovered Objects")
		if LocaleManager != null else "Pistas y Objetos Descubiertos"
	))
	if WorldState.clues_found.is_empty():
		lines.append(
			LocaleManager.pick(
				"[i]No hay pistas registradas en esta página.[/i]",
				"[i]No clues recorded on this page.[/i]"
			) if LocaleManager != null else "[i]No hay pistas registradas en esta página.[/i]"
		)
	else:
		var clue_dict: Dictionary = CLUE_LABELS_EN if is_en else CLUE_LABELS
		for clue: String in WorldState.clues_found:
			var label: String = str(clue_dict.get(clue, CLUE_LABELS.get(clue, clue)))
			lines.append("• " + label)

	# --- Decisiones Trascendentales ---
	lines.append("\n[b][color=#C9AE7C]— %s —[/color][/b]" % (
		LocaleManager.pick("Decisiones Trascendentales", "Pivotal Decisions")
		if LocaleManager != null else "Decisiones Trascendentales"
	))
	if WorldState.important_choices.is_empty():
		lines.append(
			LocaleManager.pick(
				"[i]Tus decisiones comenzarán a marcar el destino de Aldeavieja a medida que avances.[/i]",
				"[i]Your decisions will begin shaping Oldtown's destiny as you progress.[/i]"
			) if LocaleManager != null else "[i]Tus decisiones comenzarán a marcar el destino de Aldeavieja a medida que avances.[/i]"
		)
	else:
		var choice_dict: Dictionary = CHOICE_LABELS_EN if is_en else CHOICE_LABELS
		for key: String in WorldState.important_choices.keys():
			var choice_name: String = str(choice_dict.get(key, CHOICE_LABELS.get(key, key)))
			var raw_choice_val: String = str(WorldState.important_choices[key])
			var choice_val: String = _localize_choice_value(key, raw_choice_val, is_en)
			lines.append("• [b]%s:[/b] %s" % [choice_name, choice_val])

	# --- Estado del Guardián ---
	lines.append("\n[b][color=#C9AE7C]— %s —[/color][/b]" % (
		LocaleManager.pick("Estado del Guardián", "Guardian Status")
		if LocaleManager != null else "Estado del Guardián"
	))
	var dominant: String = AIProfiler.get_dominant_profile() if AIProfiler != null else "nostalgia"
	var profile_name: String = ""
	if is_en:
		profile_name = {
			"nostalgia": "Nostalgia & Bonds",
			"curiosity": "Curiosity & Investigation",
			"pragmatism": "Pragmatism & Resolution"
		}.get(dominant, "Nostalgia & Bonds")
	else:
		profile_name = {
			"nostalgia": "Nostalgia y Vínculos",
			"curiosity": "Curiosidad e Investigación",
			"pragmatism": "Pragmatismo y Resolución"
		}.get(dominant, "Nostalgia y Vínculos")

	lines.append("• %s: %s" % [
		LocaleManager.pick("Perfil dominante", "Dominant profile") if LocaleManager != null else "Perfil dominante",
		profile_name
	])
	lines.append("• %s: %d" % [
		LocaleManager.pick("Cera dorada restante", "Remaining golden wax") if LocaleManager != null else "Cera dorada restante",
		WorldState.wax_remaining
	])
	lines.append("• %s: %d" % [
		LocaleManager.pick("Nivel de exploración", "Exploration level") if LocaleManager != null else "Nivel de exploración",
		WorldState.exploration_score
	])

	journal_content_label.text = "\n".join(lines)


func _localize_choice_value(choice_key: String, raw_val: String, is_en: bool) -> String:
	if not is_en:
		match raw_val:
			"share":
				return "Compartir la memoria con toda Aldeavieja"
			"preserve":
				return "Preservar el cuaderno en soledad"
			"let_go":
				return "Dejar ir los recuerdos en paz"
			_:
				return raw_val

	match choice_key:
		"final_decision":
			match raw_val:
				"share":
					return "Share memory with all of Oldtown"
				"preserve":
					return "Preserve the notebook in solitude"
				"let_go":
					return "Let memories go in peace"
				_:
					return raw_val
		"lucia_tomas_reconstruction":
			if raw_val.contains("bicicleta") or raw_val.contains("bicycle"):
				return "Precise reconstruction: 'Tomás taught Lucía how to ride a bicycle.'"
			elif raw_val.contains("puente") or raw_val.contains("bridge"):
				return "Partial reconstruction: 'Tomás always waited for Lucía by the bridge.'"
			elif raw_val.contains("prometi") or raw_val.contains("promise"):
				return "Partial reconstruction: 'Tomás promised her he would never stop accompanying her.'"
			return raw_val
		"samuel_memory_focus":
			if raw_val.contains("inventar") or raw_val.contains("invent"):
				return "You understood that the notebook cannot invent memories."
			elif raw_val.contains("vivos") or raw_val.contains("alive"):
				return "You understood that memories need someone to keep them alive."
			elif raw_val.contains("historia") or raw_val.contains("story"):
				return "You understood that first the story disappears, and then the person."
			return raw_val
		"study_investigation_focus":
			if raw_val.contains("Elena"):
				return "You sought to understand what happened to Elena."
			elif raw_val.contains("Cuaderno") or raw_val.contains("utiliz"):
				return "You investigated why grandfather used the Wax Notebook."
			elif raw_val.contains("detener") or raw_val.contains("stano"):
				return "You focused on finding how to open the basement and stop Oblivion."
			return raw_val
		"level2_distractions_used":
			if raw_val.contains("sin usar"):
				return "Cleared the station without using distractions."
			elif raw_val.contains("Utilizaste"):
				return (
					raw_val
					.replace("Utilizaste", "Used")
					.replace("recurso(s) del entorno", "environmental resource(s)")
					.replace("último:", "last:")
					.replace("Lámpara de mantenimiento (atajo iluminado)", "Maintenance lamp (illuminated shortcut)")
					.replace("Caja de herramientas (obstáculo temporal)", "Toolbox (temporary obstacle)")
					.replace("Campana de la estación (distracción sonora)", "Station bell (sound distraction)")
				)
			return raw_val
		"prologue_silhouette":
			if raw_val.contains("niña"):
				return "In the Wax Notebook, you observed the silhouette of the young girl searching for someone."
			elif raw_val.contains("anciano"):
				return "In the Wax Notebook, you observed the silhouette of the old man holding a familiar object."
			elif raw_val.contains("tercera"):
				return "In the Wax Notebook, you observed the distant third figure watching in silence."
			elif raw_val.contains("propia"):
				return "In the Wax Notebook, you chose to observe your own silhouette before departing."
			return raw_val
		_:
			return raw_val


func _on_options_button_pressed() -> void:
	_sync_options_controls()
	main_pause_panel.hide()
	tutorial_panel.hide()
	options_panel.show()


func _on_tutorial_button_pressed() -> void:
	options_panel.hide()
	tutorial_panel.show()


func _on_close_tutorial_button_pressed() -> void:
	tutorial_panel.hide()
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
