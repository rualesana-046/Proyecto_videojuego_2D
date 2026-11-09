class_name EndingScreen
extends Control

const MAIN_MENU_PATH: String = "res://scenes/ui/CharacterCreator.tscn"

const ENDINGS_DATA: Dictionary = {
	"nostalgia": {
		"title": "Final 1: El Recuerdo Conservado",
		"description": "Aldeavieja permanece congelada en sus tradiciones. Has sellado cada página con cera antigua, preservando intacta la memoria de quienes habitaron el pueblo para que ningún recuerdo vuelva a desvanecerse."
	},
	"curiosity": {
		"title": "Final 2: El Descubrimiento del Origen",
		"description": "Se revelan los motivos profundos detrás de la pérdida de memoria. Al indagar entre los trazos ocultos del gran tomo, descubres la verdad sobre el origen del olvido y despiertas una consciencia nueva en los habitantes de Aldeavieja."
	},
	"pragmatism": {
		"title": "Final 3: El Nuevo Comienzo",
		"description": "Se acepta el cambio y la aldea avanza hacia una nueva era. En lugar de aferrarse al pasado, las páginas en blanco se convierten en el lienzo donde Aldeavieja escribe su propio futuro."
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
	ending_title_label.text = str(ending_info.get("title", ""))
	ending_description_label.text = str(ending_info.get("description", ""))


func _on_main_menu_button_pressed() -> void:
	WorldState.reset_state()
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
