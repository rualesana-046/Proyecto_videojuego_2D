class_name EndingScreen
extends Control

const CREDITS_SCREEN_PATH: String = "res://scenes/ui/CreditsScreen.tscn"

const PROFILE_NAMES_ES: Dictionary = {
	"nostalgia": "Nostalgia (Vínculo y Memoria Viva)",
	"curiosity": "Curiosidad (Búsqueda y Custodia de la Verdad)",
	"pragmatism": "Pragmatismo (Aceptación y Renovación)"
}

const PROFILE_NAMES_EN: Dictionary = {
	"nostalgia": "Nostalgia (Living Bond & Memory)",
	"curiosity": "Curiosity (Search & Custody of Truth)",
	"pragmatism": "Pragmatism (Acceptance & Renewal)"
}

const ENDINGS_DATA_ES: Dictionary = {
	"share": {
		"title": "Final 1. Una historia compartida",
		"subtitle": "Final de conexión",
		"narrative": "Al abrir el Gran Libro en el sótano, la cera dorada se eleva como una brisa cálida y recorre cada calle de Aldeavieja, devolviendo los recuerdos a quienes les pertenecen.\n\nEn la plaza central, Lucía vuelve a contar entre risas la historia de su hermano Tomás y de cómo aprendió a montar bicicleta en el antiguo puente. Frente al reloj público, cuyas agujas han vuelto a girar, Don Elías recuerda con nitidez las tardes compartidas con sus vecinos, mientras en la floristería Marta recupera las historias detrás de cada encargo escrito en su libreta.\n\nAl regresar al taller, encuentras una última nota escrita con la letra de tu abuelo sobre el cuaderno:\n[i]«Ahora lo entiendes. Las historias no necesitan permanecer intactas para seguir siendo importantes. Necesitan a alguien dispuesto a contarlas».[/i]",
		"closing_quote": "Algunas historias se olvidan. Otras cambian con el tiempo. Pero mientras alguien esté dispuesto a compartirlas, nunca desaparecerán del todo."
	},
	"preserve": {
		"title": "Final 2. El guardián de los recuerdos",
		"subtitle": "Final de preservación",
		"narrative": "Decides custodiar el Gran Libro y asumir la responsabilidad de proteger el archivo vivo de Aldeavieja. Con paciencia de encuadernador, sellas y ordenas cada testimonio para que ninguna página vuelva a extraviarse en la niebla.\n\nDe regreso en el silencio del taller, abres el Cuaderno de Cera bajo la luz de la lámpara. Sobre el papel pergamino los trazos dorados comienzan a unirse hasta dibujar con serenidad el rostro de tu abuelo. Lo contemplas en silencio y pronuncias una promesa:\n[i]—No voy a dejar que te olviden.[/i]",
		"closing_quote": "Hay recuerdos que merecen ser protegidos. Y hay historias que esperan pacientemente a que alguien vuelva a encontrarlas."
	},
	"let_go": {
		"title": "Final 3. El valor de dejar ir",
		"subtitle": "Final de aceptación",
		"narrative": "Permites que los sellos antiguos cedan sin aferrarte a ellos. La cera dorada se derrite lentamente y se transforma en miles de partículas luminosas que recorren los tejados, el puente y la antigua estación de Aldeavieja antes de disolverse en el cielo del atardecer.\n\nCuando regresas a la mesa del taller, el Cuaderno de Cera descansa abierto frente a una última página completamente blanca, lista para lo que aún no ha sucedido. Miras la ventana abierta hacia el pueblo y murmuras:\n[i]—Supongo que no todas las historias necesitan un final escrito.[/i]",
		"closing_quote": "Recordar no significa detener el tiempo. A veces, significa agradecer lo vivido y permitir que la vida continúe."
	}
}

const ENDINGS_DATA_EN: Dictionary = {
	"share": {
		"title": "Ending 1. A Shared Story",
		"subtitle": "Ending of Connection",
		"narrative": "Upon opening the Great Book in the cellar, the golden wax rises like a warm breeze and weaves through every street of Aldeavieja, returning memories to those who lived them.\n\nIn the central plaza, Lucía laughs as she recounts the tale of her brother Tomás and how she learned to ride a bicycle across the old bridge. In front of the public clock, whose hands tick once more, Don Elías vividly recalls afternoons shared with his neighbors, while at the flower shop Marta recovers the stories behind each order written in her ledger.\n\nReturning to the workshop, you find one final note written in your grandfather's hand resting on the notebook:\n[i]«Now you understand. Stories do not need to remain untouched to stay meaningful. They just need someone willing to tell them».[/i]",
		"closing_quote": "Some stories are forgotten. Others change with time. But as long as someone is willing to share them, they will never truly disappear."
	},
	"preserve": {
		"title": "Ending 2. The Guardian of Memories",
		"subtitle": "Ending of Preservation",
		"narrative": "You choose to shelter the Great Book, taking up the mantle of guarding the living archive of Aldeavieja. With a bookbinder's patience, you seal and organize each testimony so that no page may ever drift into the mist again.\n\nBack in the quiet warmth of the workshop, you open the Wax Notebook beneath the desk lamp. Across the parchment, golden strokes converge peacefully to sketch your grandfather's face. You gaze upon him in silence and whisper a vow:\n[i]—I will not let you be forgotten.[/i]",
		"closing_quote": "There are memories that deserve to be protected. And there are stories that wait patiently for someone to find them once again."
	},
	"let_go": {
		"title": "Ending 3. The Courage to Let Go",
		"subtitle": "Ending of Acceptance",
		"narrative": "You allow the ancient seals to yield without clinging to them. The golden wax gently melts away, turning into thousands of glowing motes that sweep across rooftops, the bridge, and the old station before dispersing into the dusk sky.\n\nWhen you return to the workshop table, the Wax Notebook rests open before a final, immaculate white page, ready for whatever is yet to come. Looking out the open window towards the town, you murmur:\n[i]—I suppose not all stories require a written end.[/i]",
		"closing_quote": "Remembering does not mean stopping time. Sometimes, it means cherishing what was lived and allowing life to move forward."
	}
}

@onready var ending_panel: PanelContainer = $EndingPanel
@onready var ending_title_label: Label = $EndingPanel/MarginContainer/VBoxContainer/EndingTitleLabel
@onready var ending_subtitle_label: Label = $EndingPanel/MarginContainer/VBoxContainer/EndingSubtitleLabel
@onready var ending_description_label: RichTextLabel = $EndingPanel/MarginContainer/VBoxContainer/ScrollContainer/EndingDescriptionLabel
@onready var continue_to_credits_button: Button = $EndingPanel/MarginContainer/VBoxContainer/ContinueToCreditsButton


func _ready() -> void:
	var ending_key: String = _resolve_ending_key()
	_display_ending(ending_key)
	continue_to_credits_button.pressed.connect(AudioManager.play_ui_click)
	continue_to_credits_button.pressed.connect(_on_continue_to_credits_pressed)

	if LocaleManager != null:
		LocaleManager.language_changed.connect(_on_language_changed)

	if ending_panel != null:
		ending_panel.modulate.a = 0.0
		var tween: Tween = create_tween()
		tween.tween_property(ending_panel, "modulate:a", 1.0, 0.9)


func _on_language_changed(_new_lang: String) -> void:
	var ending_key: String = _resolve_ending_key()
	_display_ending(ending_key)


func _resolve_ending_key() -> String:
	var chosen_final: String = str(WorldState.important_choices.get("final_decision", ""))
	if ENDINGS_DATA_ES.has(chosen_final):
		return chosen_final

	var dominant_profile: String = AIProfiler.get_dominant_profile()
	match dominant_profile:
		"curiosity":
			return "preserve"
		"pragmatism":
			return "let_go"
		_:
			return "share"


func _display_ending(ending_key: String) -> void:
	var is_en: bool = LocaleManager != null and LocaleManager.current_lang == "en"
	var dataset: Dictionary = ENDINGS_DATA_EN if is_en else ENDINGS_DATA_ES
	var ending_info: Dictionary = dataset.get(ending_key, dataset["share"])

	ending_title_label.text = str(ending_info.get("title", ""))
	ending_subtitle_label.text = str(ending_info.get("subtitle", ""))
	continue_to_credits_button.text = LocaleManager.pick("Continuar a Créditos", "Continue to Credits") if LocaleManager != null else "Continuar a Créditos"

	var narrative_body: String = str(ending_info.get("narrative", ""))
	var closing_quote: String = str(ending_info.get("closing_quote", ""))
	var continuity_block: String = _build_continuity_summary()

	ending_description_label.text = (
		"%s\n\n[b][color=#C9AE7C]«%s»[/color][/b]\n\n%s"
		% [narrative_body, closing_quote, continuity_block]
	)


func _build_continuity_summary() -> String:
	var is_en: bool = LocaleManager != null and LocaleManager.current_lang == "en"
	var lines: PackedStringArray = PackedStringArray()

	if is_en:
		lines.append("[b][color=#C9AE7C]— Traces of your Journey across Aldeavieja —[/color][/b]")
		if WorldState.recovered_memories.has("Recuerdo de Lucía y Tomás (Completo)"):
			lines.append("• [b]The Plaza (Lucía & Tomás):[/b] You reconstructed the memory in full; Lucía remembered precisely how Tomás taught her to ride on the bridge.")
		elif WorldState.recovered_memories.has("Recuerdo de Lucía y Tomás (Parcial)"):
			lines.append("• [b]The Plaza (Lucía & Tomás):[/b] You reconstructed the memory partially; though some details remained hazy, Lucía recovered Tomás's name and promise.")
		else:
			lines.append("• [b]The Plaza (Lucía & Tomás):[/b] Tomás's echo remained a faint imprint by the old bridge.")

		var found_station_bonus: bool = (
			WorldState.recovered_memories.has("Página adicional: Los viajes del abuelo y Samuel en la estación")
			or bool(WorldState.state.get("waiting_room_page_unlocked", false))
		)
		var escape_sec: float = float(WorldState.time_management.get("level2_escape_seconds", 0.0))
		var distractions_note: String = str(
			WorldState.important_choices.get("level2_distractions_used", "You traversed the platform cautiously.")
		)
		var station_summary: String = "• [b]The Old Station (Samuel & Inés):[/b] "
		if found_station_bonus:
			station_summary += "You found the hidden waiting room page about your grandfather and Samuel's travels. "
		else:
			station_summary += "You recovered the letter from the Clock Tower alongside Inés. "
		if escape_sec > 0.0:
			station_summary += "Switched the platform lever in %.1f s (%s)" % [escape_sec, distractions_note]
		else:
			station_summary += distractions_note
		lines.append(station_summary)

		var level3_outcome: String = str(WorldState.time_management.get("level3_outcome", "optimal"))
		var time_left: int = int(WorldState.time_management.get("level3_time_left", 0))
		if level3_outcome == "degraded":
			lines.append("• [b]The Family House (Elena & Grandfather):[/b] Memory time expired before completing all seals, unsealing the cellar with the notebook's final ember.")
		else:
			lines.append("• [b]The Family House (Elena & Grandfather):[/b] Reconstructed all three core memories in time (Time remaining: %d, Wax preserved: %d)." % [time_left, WorldState.wax_remaining])

		var dominant: String = AIProfiler.get_dominant_profile()
		var dominant_label: String = str(PROFILE_NAMES_EN.get(dominant, PROFILE_NAMES_EN["nostalgia"]))
		var n_score: int = int(AIProfiler.traits.get("nostalgia", 0))
		var c_score: int = int(AIProfiler.traits.get("curiosity", 0))
		var p_score: int = int(AIProfiler.traits.get("pragmatism", 0))

		lines.append(
			"• [b]Guardian Profile:[/b] %s\n   [i]Nostalgia: %d  |  Curiosity: %d  |  Pragmatism: %d  |  Exploration: %d  |  Memories: %d[/i]"
			% [dominant_label, n_score, c_score, p_score, WorldState.exploration_score, WorldState.recovered_memories.size()]
		)
	else:
		lines.append("[b][color=#C9AE7C]— Huellas de tu recorrido por Aldeavieja —[/color][/b]")
		if WorldState.recovered_memories.has("Recuerdo de Lucía y Tomás (Completo)"):
			lines.append("• [b]La Plaza (Lucía y Tomás):[/b] Reconstruiste el recuerdo de forma completa; Lucía recordó con exactitud cómo Tomás le enseñó a montar bicicleta en el puente.")
		elif WorldState.recovered_memories.has("Recuerdo de Lucía y Tomás (Parcial)"):
			lines.append("• [b]La Plaza (Lucía y Tomás):[/b] Reconstruiste el recuerdo de manera parcial; aunque algunos matices quedaron difusos, Lucía recuperó el nombre y la promesa de Tomás.")
		else:
			lines.append("• [b]La Plaza (Lucía y Tomás):[/b] El eco de Tomás permaneció como una huella tenue junto al antiguo puente.")

		var found_station_bonus: bool = (
			WorldState.recovered_memories.has("Página adicional: Los viajes del abuelo y Samuel en la estación")
			or bool(WorldState.state.get("waiting_room_page_unlocked", false))
		)
		var escape_sec: float = float(WorldState.time_management.get("level2_escape_seconds", 0.0))
		var distractions_note: String = str(
			WorldState.important_choices.get("level2_distractions_used", "Recorriste el andén con cautela.")
		)
		var station_summary: String = "• [b]La Antigua Estación (Samuel e Inés):[/b] "
		if found_station_bonus:
			station_summary += "Descubriste la página oculta de la sala de espera sobre los viajes de tu abuelo y Samuel. "
		else:
			station_summary += "Recuperaste la carta de la Torre del Reloj junto a Inés. "
		if escape_sec > 0.0:
			station_summary += "Activaste la palanca del andén en %.1f s (%s)" % [escape_sec, distractions_note]
		else:
			station_summary += distractions_note
		lines.append(station_summary)

		var level3_outcome: String = str(WorldState.time_management.get("level3_outcome", "optimal"))
		var time_left: int = int(WorldState.time_management.get("level3_time_left", 0))
		if level3_outcome == "degraded":
			lines.append("• [b]La Casa Familiar (Elena y el Abuelo):[/b] El tiempo del recuerdo se agotó antes de completar todos los sellos, abriendo el sótano con la última chispa del cuaderno.")
		else:
			lines.append("• [b]La Casa Familiar (Elena y el Abuelo):[/b] Reconstruiste los tres recuerdos fundamentales a tiempo (Tiempo restante: %d, Cera conservada: %d)." % [time_left, WorldState.wax_remaining])

		var dominant: String = AIProfiler.get_dominant_profile()
		var dominant_label: String = str(PROFILE_NAMES_ES.get(dominant, PROFILE_NAMES_ES["nostalgia"]))
		var n_score: int = int(AIProfiler.traits.get("nostalgia", 0))
		var c_score: int = int(AIProfiler.traits.get("curiosity", 0))
		var p_score: int = int(AIProfiler.traits.get("pragmatism", 0))

		lines.append(
			"• [b]Perfil del Guardián:[/b] %s\n   [i]Nostalgia: %d  |  Curiosidad: %d  |  Pragmatismo: %d  |  Exploración: %d  |  Recuerdos: %d[/i]"
			% [dominant_label, n_score, c_score, p_score, WorldState.exploration_score, WorldState.recovered_memories.size()]
		)

	return "\n".join(lines)


func _on_continue_to_credits_pressed() -> void:
	get_tree().change_scene_to_file(CREDITS_SCREEN_PATH)
