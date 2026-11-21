class_name EndingScreen
extends Control

const MAIN_MENU_PATH: String = "res://scenes/ui/MainMenu.tscn"

const ENDINGS_DATA: Dictionary = {
	"nostalgia": {
		"title": "Final 1: El Recuerdo Conservado",
		"profile_label": "Perfil Dominante: Nostalgia (Guardián de la Tradición)",
		"description": "Siguiendo las enseñanzas del Maestro Encuadernador, utilizaste los Fragmentos de Cera y tu Cuaderno de Cera para sellar cada página del Gran Tomo Fundacional tal como fue escrita. Elena recuperó la canción de cuna de su madre y el nombre de la antigua biblioteca volvió a los labios del pueblo. Aldeavieja permanece resguardada en la calidez de sus tradiciones, inmune al paso del tiempo y al Olvido."
	},
	"curiosity": {
		"title": "Final 2: El Descubrimiento del Origen",
		"profile_label": "Perfil Dominante: Curiosidad (Buscador de la Verdad)",
		"description": "En lugar de limitarte a sellar las grietas del Gran Tomo, empleaste el Cuaderno de Cera para rastrear el origen de la niebla blanca más allá de las Ruinas del Olvido. Descubriste que los Recolectores eran antiguos escribas que intentaban borrar un capítulo prohibido de la fundación de Aldeavieja. Al revelar la verdad completa ante el Maestro Encuadernador, el pueblo despertó a una comprensión más profunda de su propia historia."
	},
	"pragmatism": {
		"title": "Final 3: El Nuevo Comienzo",
		"profile_label": "Perfil Dominante: Pragmatismo (Arquitecto del Mañana)",
		"description": "Con determinación y temple en el Taller de Encuadernación, reuniste los Fragmentos de Cera no para aferrarte a lo que ya se había desvanecido, sino para encuadernar un tomo nuevo y resistente. Junto al Maestro Encuadernador y los habitantes de Aldeavieja, transformaste las páginas en blanco en el lienzo de una nueva era, donde el pueblo escribe su futuro sin temor al cambio."
	}
}

@onready var ending_title_label: Label = $EndingPanel/VBoxContainer/EndingTitleLabel
@onready var ending_description_label: RichTextLabel = $EndingPanel/VBoxContainer/EndingDescriptionLabel
@onready var main_menu_button: Button = $EndingPanel/VBoxContainer/MainMenuButton


func _ready() -> void:
	var profile: String = AIProfiler.get_dominant_profile()
	_display_ending(profile)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)


func _display_ending(profile: String) -> void:
	var ending_info: Dictionary = ENDINGS_DATA.get(profile, ENDINGS_DATA["nostalgia"])
	var profile_label: String = str(ending_info.get("profile_label", ""))
	var narrative_text: String = str(ending_info.get("description", ""))
	var nostalgia_score: int = int(AIProfiler.traits.get("nostalgia", 0))
	var curiosity_score: int = int(AIProfiler.traits.get("curiosity", 0))
	var pragmatism_score: int = int(AIProfiler.traits.get("pragmatism", 0))
	var fragments_count: int = WorldState.wax_fragments

	ending_title_label.text = str(ending_info.get("title", ""))
	ending_description_label.text = (
		"%s\n\n[b]%s[/b]\nNostalgia: %d  |  Curiosidad: %d  |  Pragmatismo: %d  |  Cera recolectada: %d"
		% [narrative_text, profile_label, nostalgia_score, curiosity_score, pragmatism_score, fragments_count]
	)


func _on_main_menu_button_pressed() -> void:
	WorldState.reset_state()
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
