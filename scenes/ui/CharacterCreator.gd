class_name CharacterCreator
extends Control

const FIRST_LEVEL_PATH: String = "res://scenes/levels/Level1.tscn"

const BODY_PALETTE: Array[Color] = [
	Color.WHITE,
	Color(0.8, 0.6, 0.4),
	Color(0.4, 0.2, 0.1)
]
const HAIR_PALETTE: Array[Color] = [
	Color(0.4, 0.2, 0.1),
	Color(0.9, 0.8, 0.3),
	Color(0.1, 0.1, 0.1)
]
const CLOTHES_PALETTE: Array[Color] = [
	Color(0.02, 0.16, 0.14),
	Color(0.78, 0.68, 0.48),
	Color(0.6, 0.1, 0.1)
]

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


func _create_color_icon(color: Color) -> Texture2D:
	var img: Image = Image.create_empty(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)


func _populate_options() -> void:
	body_option.clear()
	for color: Color in BODY_PALETTE:
		body_option.add_icon_item(_create_color_icon(color), "")
	body_option.selected = 0

	hair_option.clear()
	for color: Color in HAIR_PALETTE:
		hair_option.add_icon_item(_create_color_icon(color), "")
	hair_option.selected = 0

	clothes_option.clear()
	for color: Color in CLOTHES_PALETTE:
		clothes_option.add_icon_item(_create_color_icon(color), "")
	clothes_option.selected = 0


func _on_body_option_selected(index: int) -> void:
	if index < 0 or index >= BODY_PALETTE.size():
		return
	var selected_color: Color = BODY_PALETTE[index]
	WorldState.player_colors["body"] = selected_color
	preview_body_sprite.modulate = selected_color


func _on_hair_option_selected(index: int) -> void:
	if index < 0 or index >= HAIR_PALETTE.size():
		return
	var selected_color: Color = HAIR_PALETTE[index]
	WorldState.player_colors["hair"] = selected_color
	preview_hair_sprite.modulate = selected_color


func _on_clothes_option_selected(index: int) -> void:
	if index < 0 or index >= CLOTHES_PALETTE.size():
		return
	var selected_color: Color = CLOTHES_PALETTE[index]
	WorldState.player_colors["clothes"] = selected_color
	preview_clothes_sprite.modulate = selected_color


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(FIRST_LEVEL_PATH)
