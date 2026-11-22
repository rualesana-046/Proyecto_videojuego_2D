class_name CharacterCreator
extends Control

const FIRST_LEVEL_PATH: String = "res://scenes/levels/Prologue.tscn"
const MAIN_MENU_PATH: String = "res://scenes/ui/MainMenu.tscn"

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

@onready var title_label: Label = $MainContainer/TitleLabel
@onready var body_color_label: Label = $MainContainer/BodyColorRow/BodyColorLabel
@onready var hair_color_label: Label = $MainContainer/HairColorRow/HairColorLabel
@onready var clothes_color_label: Label = $MainContainer/ClothesColorRow/ClothesColorLabel

@onready var preview_body_sprite: Sprite2D = $MainContainer/PreviewContainer/PreviewVisuals/BodySprite
@onready var preview_clothes_sprite: Sprite2D = $MainContainer/PreviewContainer/PreviewVisuals/ClothesSprite
@onready var preview_hair_sprite: Sprite2D = $MainContainer/PreviewContainer/PreviewVisuals/HairSprite

@onready var body_option: OptionButton = $MainContainer/BodyColorRow/BodyOption
@onready var hair_option: OptionButton = $MainContainer/HairColorRow/HairOption
@onready var clothes_option: OptionButton = $MainContainer/ClothesColorRow/ClothesOption
@onready var start_button: Button = $MainContainer/StartButton
@onready var back_button: Button = $MainContainer/BackButton


func _ready() -> void:
	_populate_options()
	_on_body_option_selected(0)
	_on_hair_option_selected(0)
	_on_clothes_option_selected(0)

	body_option.item_selected.connect(_on_body_option_selected)
	hair_option.item_selected.connect(_on_hair_option_selected)
	clothes_option.item_selected.connect(_on_clothes_option_selected)
	start_button.pressed.connect(AudioManager.play_ui_click)
	back_button.pressed.connect(AudioManager.play_ui_click)
	start_button.pressed.connect(_on_start_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

	if LocaleManager != null:
		LocaleManager.language_changed.connect(_on_language_changed)

	_update_locale_texts()


func _create_color_icon(color: Color) -> Texture2D:
	var img: Image = Image.create_empty(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)


func _populate_options() -> void:
	var prev_body: int = maxi(0, body_option.selected)
	var prev_hair: int = maxi(0, hair_option.selected)
	var prev_clothes: int = maxi(0, clothes_option.selected)

	var body_names: Array[String] = [
		LocaleManager.t("tone_light") if LocaleManager != null else "Claro",
		LocaleManager.t("tone_medium") if LocaleManager != null else "Medio",
		LocaleManager.t("tone_dark") if LocaleManager != null else "Oscuro"
	]
	var hair_names: Array[String] = [
		LocaleManager.t("hair_brown") if LocaleManager != null else "Castaño",
		LocaleManager.t("hair_blonde") if LocaleManager != null else "Rubio",
		LocaleManager.t("hair_black") if LocaleManager != null else "Negro"
	]
	var clothes_names: Array[String] = [
		LocaleManager.t("clothes_emerald") if LocaleManager != null else "Verde Esmeralda",
		LocaleManager.t("clothes_gold") if LocaleManager != null else "Dorado Cera",
		LocaleManager.t("clothes_crimson") if LocaleManager != null else "Carmesí"
	]

	body_option.clear()
	for i: int in range(BODY_PALETTE.size()):
		body_option.add_icon_item(_create_color_icon(BODY_PALETTE[i]), body_names[i])
	body_option.selected = prev_body

	hair_option.clear()
	for i: int in range(HAIR_PALETTE.size()):
		hair_option.add_icon_item(_create_color_icon(HAIR_PALETTE[i]), hair_names[i])
	hair_option.selected = prev_hair

	clothes_option.clear()
	for i: int in range(CLOTHES_PALETTE.size()):
		clothes_option.add_icon_item(_create_color_icon(CLOTHES_PALETTE[i]), clothes_names[i])
	clothes_option.selected = prev_clothes


func _update_locale_texts() -> void:
	if LocaleManager == null:
		return

	title_label.text = LocaleManager.t("char_title")
	body_color_label.text = LocaleManager.t("body_color")
	hair_color_label.text = LocaleManager.t("hair_color")
	clothes_color_label.text = LocaleManager.t("clothes_color")
	start_button.text = LocaleManager.t("start_adventure")
	back_button.text = LocaleManager.t("back")
	_populate_options()


func _on_language_changed(_new_lang: String) -> void:
	_update_locale_texts()


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
	WorldState.current_level = FIRST_LEVEL_PATH
	get_tree().change_scene_to_file(FIRST_LEVEL_PATH)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
