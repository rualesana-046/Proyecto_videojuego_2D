extends Node

signal language_changed(new_lang: String)

const SETTINGS_PATH: String = "user://settings.cfg"
const UI_TRANSLATIONS_PATH: String = "res://assets/data/ui_translations.json"

var current_lang: String = "es"
var _translations: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_translations()
	_load_saved_settings()


func _load_translations() -> void:
	if not FileAccess.file_exists(UI_TRANSLATIONS_PATH):
		push_warning("LocaleManager: UI translations file not found at " + UI_TRANSLATIONS_PATH)
		return

	var file: FileAccess = FileAccess.open(UI_TRANSLATIONS_PATH, FileAccess.READ)
	if file == null:
		push_warning("LocaleManager: Could not open " + UI_TRANSLATIONS_PATH)
		return

	var content: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(content)
	if parsed is Dictionary:
		_translations = parsed
	else:
		push_warning("LocaleManager: Expected dictionary in " + UI_TRANSLATIONS_PATH)


func _load_saved_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load(SETTINGS_PATH)
	if err == OK:
		var saved_lang: String = str(config.get_value("locale", "language", "es"))
		if saved_lang == "es" or saved_lang == "en":
			current_lang = saved_lang


func set_language(lang: String) -> void:
	var target_lang: String = lang.to_lower()
	if target_lang != "es" and target_lang != "en":
		target_lang = "es"

	current_lang = target_lang

	var config: ConfigFile = ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("locale", "language", current_lang)
	config.save(SETTINGS_PATH)

	language_changed.emit(current_lang)


func toggle_language() -> void:
	if current_lang == "es":
		set_language("en")
	else:
		set_language("es")


func t(key: String) -> String:
	if _translations.has(key) and _translations[key] is Dictionary:
		var entry: Dictionary = _translations[key]
		if entry.has(current_lang):
			return str(entry[current_lang])
		elif entry.has("es"):
			return str(entry["es"])
	return key


func pick(es_text: String, en_text: String) -> String:
	if current_lang == "en":
		return en_text
	return es_text


func get_language_name() -> String:
	if current_lang == "en":
		return "English"
	return "Español"
