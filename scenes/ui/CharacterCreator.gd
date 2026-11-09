class_name CharacterCreator
extends Control

const FIRST_LEVEL_PATH: String = "res://scenes/levels/Level1.tscn"

const BODY_PALETTE: Dictionary = {
	"Clara": Color.WHITE,
	"Morena": Color(0.8, 0.6, 0.4),
	"Oscura": Color(0.4, 0.2, 0.1)
}
const HAIR_PALETTE: Dictionary = {
	"Castaño": Color(0.4, 0.2, 0.1),
	"Rubio": Color(0.9, 0.8, 0.3),
	"Negro": Color(0.1, 0.1, 0.1)
}
const CLOTHES_PALETTE: Dictionary = {
	"Esmeralda": Color(0.02, 0.16, 0.14),
	"Dorado": Color(0.78, 0.68, 0.48),
	"Carmesí": Color(0.6, 0.1, 0.1)
}

@onready var preview_body_sprite: Sprite2D = $MainContainer/PreviewContainer/PreviewVisuals/BodySprite
@onready var preview_clothes_sprite: Sprite2D = $MainContainer/PreviewContainer/PreviewVisuals/ClothesSprite
@onready var preview_hair_sprite: Sprite2D = $MainContainer/PreviewContainer/PreviewVisuals/HairSprite

@onready var body_option: OptionButton = $MainContainer/BodyColorRow/BodyOption
@onready var hair_option: OptionButton = $MainContainer/HairColorRow/HairOption
@onready var clothes_option: OptionButton = $MainContainer/ClothesColorRow/ClothesOption
@onready var start_button: Button = $MainContainer/StartButton


func _ready() -> void:
	_populate_options()
	_on_body_option_selected(0)
	_on_hair_option_selected(0)
	_on_clothes_option_selected(0)

	body_option.item_selected.connect(_on_body_option_selected)
	hair_option.item_selected.connect(_on_hair_option_selected)
	clothes_option.item_selected.connect(_on_clothes_option_selected)
	start_button.pressed.connect(_on_start_button_pressed)


func _populate_options() -> void:
	body_option.clear()
	for option_name: Variant in BODY_PALETTE.keys():
		body_option.add_item(str(option_name))
	body_option.selected = 0

	hair_option.clear()
	for option_name: Variant in HAIR_PALETTE.keys():
		hair_option.add_item(str(option_name))
	hair_option.selected = 0

	clothes_option.clear()
	for option_name: Variant in CLOTHES_PALETTE.keys():
		clothes_option.add_item(str(option_name))
	clothes_option.selected = 0


func _on_body_option_selected(index: int) -> void:
	var selected_key: String = body_option.get_item_text(index)
	var selected_color: Color = BODY_PALETTE.get(selected_key, Color.WHITE)
	WorldState.player_colors["body"] = selected_color
	preview_body_sprite.modulate = selected_color


func _on_hair_option_selected(index: int) -> void:
	var selected_key: String = hair_option.get_item_text(index)
	var selected_color: Color = HAIR_PALETTE.get(selected_key, Color(0.4, 0.2, 0.1))
	WorldState.player_colors["hair"] = selected_color
	preview_hair_sprite.modulate = selected_color


func _on_clothes_option_selected(index: int) -> void:
	var selected_key: String = clothes_option.get_item_text(index)
	var selected_color: Color = CLOTHES_PALETTE.get(selected_key, Color(0.02, 0.16, 0.14))
	WorldState.player_colors["clothes"] = selected_color
	preview_clothes_sprite.modulate = selected_color


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(FIRST_LEVEL_PATH)
