class_name CharacterCreator
extends Control

const FIRST_LEVEL_PATH: String = "res://scenes/levels/Level1.tscn"

@onready var preview_body_sprite: Sprite2D = $MainContainer/PreviewContainer/PreviewVisuals/BodySprite
@onready var preview_clothes_sprite: Sprite2D = $MainContainer/PreviewContainer/PreviewVisuals/ClothesSprite
@onready var preview_hair_sprite: Sprite2D = $MainContainer/PreviewContainer/PreviewVisuals/HairSprite

@onready var body_color_picker: ColorPickerButton = $MainContainer/BodyColorRow/BodyColorPicker
@onready var hair_color_picker: ColorPickerButton = $MainContainer/HairColorRow/HairColorPicker
@onready var clothes_color_picker: ColorPickerButton = $MainContainer/ClothesColorRow/ClothesColorPicker
@onready var start_button: Button = $MainContainer/StartButton


func _ready() -> void:
	_initialize_colors()
	body_color_picker.color_changed.connect(_on_body_color_changed)
	hair_color_picker.color_changed.connect(_on_hair_color_changed)
	clothes_color_picker.color_changed.connect(_on_clothes_color_changed)
	start_button.pressed.connect(_on_start_button_pressed)


func _initialize_colors() -> void:
	var initial_body_color: Color = WorldState.player_colors.get("body", Color.WHITE)
	var initial_hair_color: Color = WorldState.player_colors.get("hair", Color(0.2, 0.2, 0.2))
	var initial_clothes_color: Color = WorldState.player_colors.get("clothes", Color(0.02, 0.16, 0.14))

	body_color_picker.color = initial_body_color
	hair_color_picker.color = initial_hair_color
	clothes_color_picker.color = initial_clothes_color

	preview_body_sprite.modulate = initial_body_color
	preview_hair_sprite.modulate = initial_hair_color
	preview_clothes_sprite.modulate = initial_clothes_color


func _on_body_color_changed(color: Color) -> void:
	WorldState.player_colors["body"] = color
	preview_body_sprite.modulate = color


func _on_hair_color_changed(color: Color) -> void:
	WorldState.player_colors["hair"] = color
	preview_hair_sprite.modulate = color


func _on_clothes_color_changed(color: Color) -> void:
	WorldState.player_colors["clothes"] = color
	preview_clothes_sprite.modulate = color


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(FIRST_LEVEL_PATH)
