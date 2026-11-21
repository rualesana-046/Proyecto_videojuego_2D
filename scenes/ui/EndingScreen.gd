class_name EndingScreen
extends Control

const CREDITS_SCREEN_PATH: String = "res://scenes/ui/CreditsScreen.tscn"

const PROFILE_NAMES: Dictionary = {
	"nostalgia": "Nostalgia (Vínculo y Memoria Viva)",
	"curiosity": "Curiosidad (Búsqueda y Custodia de la Verdad)",
	"pragmatism": "Pragmatismo (Aceptación y Renovación)"
}

const ENDINGS_DATA: Dictionary = {
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

@onready var ending_panel: PanelContainer = $EndingPanel
@onready var ending_title_label: Label = $EndingPanel/MarginContainer/VBoxContainer/EndingTitleLabel
@onready var ending_subtitle_label: Label = $EndingPanel/MarginContainer/VBoxContainer/EndingSubtitleLabel
@onready var ending_description_label: RichTextLabel = $EndingPanel/MarginContainer/VBoxContainer/ScrollContainer/EndingDescriptionLabel
@onready var continue_to_credits_button: Button = $EndingPanel/MarginContainer/VBoxContainer/ContinueToCreditsButton


func _ready() -> void:
	var ending_key: String = _resolve_ending_key()
	_display_ending(ending_key)
	continue_to_credits_button.pressed.connect(_on_continue_to_credits_pressed)

	if ending_panel != null:
		ending_panel.modulate.a = 0.0
		var tween: Tween = create_tween()
		tween.tween_property(ending_panel, "modulate:a", 1.0, 0.9)


func _resolve_ending_key() -> String:
	var chosen_final: String = str(WorldState.important_choices.get("final_decision", ""))
	if ENDINGS_DATA.has(chosen_final):
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
	var ending_info: Dictionary = ENDINGS_DATA.get(ending_key, ENDINGS_DATA["share"])
	ending_title_label.text = str(ending_info.get("title", ""))
	ending_subtitle_label.text = str(ending_info.get("subtitle", ""))

	var narrative_body: String = str(ending_info.get("narrative", ""))
	var closing_quote: String = str(ending_info.get("closing_quote", ""))
	var continuity_block: String = _build_continuity_summary()

	ending_description_label.text = (
		"%s\n\n[b][color=#C9AE7C]«%s»[/color][/b]\n\n%s"
		% [narrative_body, closing_quote, continuity_block]
	)


func _build_continuity_summary() -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[b][color=#C9AE7C]— Huellas de tu recorrido por Aldeavieja —[/color][/b]")

	# 1. Nivel 1: Recuerdo de Lucía y Tomás
	if WorldState.recovered_memories.has("Recuerdo de Lucía y Tomás (Completo)"):
		lines.append("• [b]La Plaza (Lucía y Tomás):[/b] Reconstruiste el recuerdo de forma completa; Lucía recordó con exactitud cómo Tomás le enseñó a montar bicicleta en el puente.")
	elif WorldState.recovered_memories.has("Recuerdo de Lucía y Tomás (Parcial)"):
		lines.append("• [b]La Plaza (Lucía y Tomás):[/b] Reconstruiste el recuerdo de manera parcial; aunque algunos matices quedaron difusos, Lucía recuperó el nombre y la promesa de Tomás.")
	else:
		lines.append("• [b]La Plaza (Lucía y Tomás):[/b] El eco de Tomás permaneció como una huella tenue junto al antiguo puente.")

	# 2. Nivel 2: La Antigua Estación
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

	# 3. Nivel 3: La Casa de los Recuerdos
	var level3_outcome: String = str(WorldState.time_management.get("level3_outcome", "optimal"))
	var time_left: int = int(WorldState.time_management.get("level3_time_left", 0))
	if level3_outcome == "degraded":
		lines.append("• [b]La Casa Familiar (Elena y el Abuelo):[/b] El tiempo del recuerdo se agotó antes de completar todos los sellos, abriendo el sótano con la última chispa del cuaderno.")
	else:
		lines.append("• [b]La Casa Familiar (Elena y el Abuelo):[/b] Reconstruiste los tres recuerdos fundamentales a tiempo (Tiempo restante: %d, Cera conservada: %d)." % [time_left, WorldState.wax_remaining])

	# 4. Perfil narrativo de AIProfiler
	var dominant: String = AIProfiler.get_dominant_profile()
	var dominant_label: String = str(PROFILE_NAMES.get(dominant, PROFILE_NAMES["nostalgia"]))
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
