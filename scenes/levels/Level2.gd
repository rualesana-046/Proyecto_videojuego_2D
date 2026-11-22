class_name Level2
extends Node2D

const MAX_LIVES: int = 3
const RESPAWN_POSITION: Vector2 = Vector2(-48, 24)
const CHASER_SPAWN_POSITION: Vector2 = Vector2(-96, -8)

var player_lives: int = MAX_LIVES
var _is_invulnerable: bool = false
var _invulnerability_tween: Tween = null
var _pursuit_start_msec: int = 0
var _distractions_used_count: int = 0
var _tower_gate_opened: bool = false
var _desvanecido_vanished: bool = false
var _notification_tween: Tween = null

@onready var environment_layer: TileMapLayer = $EnvironmentLayer
@onready var player: Player = $Player
@onready var chaser: Chaser = $Chaser

@onready var samuel_photo_area: Area2D = $SamuelPhotoArea
@onready var samuel_photo_prompt: Node2D = $SamuelPhotoArea/InteractPrompt
@onready var maintenance_lamp_area: Area2D = $MaintenanceLampArea
@onready var maintenance_lamp_prompt: Node2D = $MaintenanceLampArea/InteractPrompt
@onready var toolbox_area: Area2D = $ToolboxArea
@onready var toolbox_prompt: Node2D = $ToolboxArea/InteractPrompt
@onready var toolbox_barricade: StaticBody2D = $ToolboxBarricade
@onready var station_bell_area: Area2D = $StationBellArea
@onready var station_bell_prompt: Node2D = $StationBellArea/InteractPrompt
@onready var signal_lever_area: Area2D = $SignalLeverArea
@onready var signal_lever_prompt: Node2D = $SignalLeverArea/InteractPrompt
@onready var clock_tower_box_area: Area2D = $ClockTowerBoxArea
@onready var clock_tower_box_prompt: Node2D = $ClockTowerBoxArea/InteractPrompt

@onready var objective_panel: PanelContainer = $NotificationLayer/ObjectivePanel
@onready var objective_label: Label = $NotificationLayer/ObjectivePanel/MarginContainer/ObjectiveLabel
@onready var lives_panel: PanelContainer = $NotificationLayer/LivesPanel
@onready var lives_label: Label = $NotificationLayer/LivesPanel/MarginContainer/LivesLabel
@onready var notification_panel: PanelContainer = $NotificationLayer/NotificationPanel
@onready var notification_label: Label = $NotificationLayer/NotificationPanel/MarginContainer/NotificationLabel

var _near_samuel_photo: bool = false
var _near_lamp: bool = false
var _near_toolbox: bool = false
var _near_bell: bool = false
var _near_lever: bool = false
var _near_tower_box: bool = false
var _lamp_activated: bool = false
var _barricade_active: bool = false


func _ready() -> void:
	WorldState.current_level = "res://scenes/levels/Level2.tscn"
	_update_lives_hud()
	_update_objective_hud()
	if notification_panel != null:
		notification_panel.hide()
		notification_panel.modulate.a = 0.0

	if toolbox_barricade != null:
		_set_barricade_enabled(false)

	if chaser != null:
		chaser.starts_active = false
		chaser.set_active_state(false)
		chaser.player_caught.connect(_on_chaser_player_caught)

	_connect_interactive_area(samuel_photo_area, "_on_samuel_photo_near")
	_connect_interactive_area(maintenance_lamp_area, "_on_lamp_near")
	_connect_interactive_area(toolbox_area, "_on_toolbox_near")
	_connect_interactive_area(station_bell_area, "_on_bell_near")
	_connect_interactive_area(signal_lever_area, "_on_lever_near")
	_connect_interactive_area(clock_tower_box_area, "_on_tower_box_near")

	DialogueManager.dialogue_started.connect(_update_all_prompts)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	WorldState.status_notification_requested.connect(_show_notification)
	WorldState.clue_registered.connect(func(_c: String, _t: int) -> void: _update_objective_hud())
	WorldState.memory_reconstructed.connect(func(_m: String) -> void: _update_objective_hud())

	_update_all_prompts()


func _connect_interactive_area(area: Area2D, callback_name: String) -> void:
	if area == null:
		return
	area.body_entered.connect(Callable(self, callback_name).bind(true))
	area.body_exited.connect(Callable(self, callback_name).bind(false))


func _unhandled_input(event: InputEvent) -> void:
	if DialogueManager.is_dialogue_active or not event.is_action_pressed("interact"):
		return

	if _near_samuel_photo:
		_interact_samuel_photo()
		get_viewport().set_input_as_handled()
	elif _near_lamp:
		_interact_maintenance_lamp()
		get_viewport().set_input_as_handled()
	elif _near_toolbox:
		_interact_toolbox()
		get_viewport().set_input_as_handled()
	elif _near_bell:
		_interact_station_bell()
		get_viewport().set_input_as_handled()
	elif _near_lever:
		_interact_signal_lever()
		get_viewport().set_input_as_handled()
	elif _near_tower_box:
		_interact_clock_tower_box()
		get_viewport().set_input_as_handled()


func _interact_samuel_photo() -> void:
	DialogueManager.start_dialogue("estacion_foto_samuel")


func _interact_maintenance_lamp() -> void:
	if _lamp_activated:
		_show_notification("La lámpara de mantenimiento ya ilumina el atajo hacia el andén.")
		return

	_lamp_activated = true
	_register_distraction_used("Lámpara de mantenimiento (atajo iluminado)")

	# Abre el atajo oculto entre el pasillo de mantenimiento y el andén central
	if environment_layer != null:
		environment_layer.erase_cell(Vector2i(-4, -3))
		environment_layer.erase_cell(Vector2i(-4, -2))

	if maintenance_lamp_area != null:
		maintenance_lamp_area.modulate = Color(1.3, 1.2, 0.9, 1.0)

	_show_notification("La lámpara ilumina el pasillo y abre un atajo directo hacia el andén.")


func _interact_toolbox() -> void:
	if _barricade_active:
		_show_notification("La caja de herramientas ya está bloqueando el pasillo.")
		return

	_barricade_active = true
	_register_distraction_used("Caja de herramientas (obstáculo temporal)")
	_set_barricade_enabled(true)
	_show_notification("Colocas herramientas en el pasillo para bloquear el paso durante 5 segundos.")

	var timer: SceneTreeTimer = get_tree().create_timer(5.0)
	timer.timeout.connect(_on_barricade_timeout)


func _on_barricade_timeout() -> void:
	_barricade_active = false
	_set_barricade_enabled(false)


func _set_barricade_enabled(enabled: bool) -> void:
	if toolbox_barricade == null:
		return
	toolbox_barricade.visible = enabled
	var shape: CollisionShape2D = toolbox_barricade.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape != null:
		shape.set_deferred("disabled", not enabled)


func _interact_station_bell() -> void:
	_register_distraction_used("Campana de la estación (distracción sonora)")
	if chaser != null and chaser.is_active:
		chaser.distract_to(station_bell_area.global_position, 4.0)
		_show_notification("¡El tañido de la campana atrae a El Desvanecido durante 4 segundos!")
	else:
		_show_notification("Haces sonar la campana de latón; su eco recorre los rieles vacíos.")


func _interact_signal_lever() -> void:
	if not _tower_gate_opened:
		_tower_gate_opened = true
		if _pursuit_start_msec > 0:
			var elapsed_sec: float = snappedf((Time.get_ticks_msec() - _pursuit_start_msec) / 1000.0, 0.1)
			WorldState.time_management["level2_escape_seconds"] = elapsed_sec
		else:
			WorldState.time_management["level2_escape_seconds"] = 0.0

		# Abre la reja norte hacia la Torre del Reloj
		if environment_layer != null:
			environment_layer.erase_cell(Vector2i(-1, -7))
			environment_layer.erase_cell(Vector2i(0, -7))

	_update_objective_hud()
	DialogueManager.start_dialogue("recuerdo_samuel")


func _interact_clock_tower_box() -> void:
	var has_key: bool = (
		bool(WorldState.state.get("has_station_key", false))
		or WorldState.clues_found.has("llave_estacion")
	)
	if not has_key:
		DialogueManager.show_custom_message(
			"Caja metálica del abuelo",
			"Una caja metálica cerrada con candado bajo los engranajes de la torre. Inés, en la sala de espera al suroeste, conserva la llave antigua."
		)
		return

	DialogueManager.start_dialogue("carta_abuelo_torre")


func _register_distraction_used(distraction_name: String) -> void:
	_distractions_used_count += 1
	WorldState.important_choices["level2_distractions_used"] = (
		"Utilizaste %d recurso(s) del entorno (último: %s)." % [_distractions_used_count, distraction_name]
	)


func _on_dialogue_ended() -> void:
	_update_all_prompts()
	_check_waiting_room_bonus()
	_update_objective_hud()

	# Si acaba de examinar la foto de Samuel (Escena 2), activar a El Desvanecido
	if bool(WorldState.state.get("samuel_photo_examined", false)) and not _desvanecido_vanished:
		if chaser != null and not chaser.is_active:
			_pursuit_start_msec = Time.get_ticks_msec()
			if not WorldState.important_choices.has("level2_distractions_used"):
				WorldState.important_choices["level2_distractions_used"] = "Superaste la estación sin usar distracciones."
			chaser.activate_at(CHASER_SPAWN_POSITION)
			_show_notification("El Desvanecido recorre los pasillos... llega a la palanca del andén este.")

	# Si acaba de leer la Carta del Abuelo en la torre (Escena 4), desvanecer a El Desvanecido con "Olvido"
	if bool(WorldState.state.get("clock_tower_letter_read", false)) and not _desvanecido_vanished:
		_desvanecido_vanished = true
		if chaser != null:
			chaser.global_position = Vector2(0, -104)
			chaser.show()
			chaser.vanish_with_whisper("Olvido")
		_show_notification("El sendero norte hacia la antigua casa familiar se ha desbloqueado.")


func _check_waiting_room_bonus() -> void:
	if bool(WorldState.state.get("waiting_room_page_unlocked", false)):
		return

	var has_all_waiting_items: bool = (
		WorldState.inspected_objects.has("waiting_room_photos")
		and WorldState.inspected_objects.has("waiting_room_schedule")
		and WorldState.inspected_objects.has("waiting_room_lost_box")
	)
	if has_all_waiting_items:
		WorldState.state["waiting_room_page_unlocked"] = true
		WorldState.register_recovered_memory("Página adicional: Los viajes del abuelo y Samuel en la estación")
		_show_notification("Nueva página en el Cuaderno de Cera: «Los viajes del abuelo y Samuel».")


func _update_objective_hud() -> void:
	if objective_label == null:
		return

	var has_key: bool = bool(WorldState.state.get("has_station_key", false)) or WorldState.clues_found.has("llave_estacion")
	var photo_examined: bool = bool(WorldState.state.get("samuel_photo_examined", false))
	var lever_pulled: bool = bool(WorldState.state.get("station_lever_pulled", false))
	var letter_read: bool = bool(WorldState.state.get("clock_tower_letter_read", false))

	if letter_read:
		objective_label.text = "Objetivo: Avanza por la salida norte hacia la Casa de los Recuerdos."
	elif lever_pulled:
		objective_label.text = "Objetivo: Sube a la Torre del Reloj (norte) y abre la caja metálica con la llave."
	elif photo_examined:
		objective_label.text = "Objetivo: Usa lámpara, caja o campana para distraer al Desvanecido y activa la palanca en el andén (este)."
	elif has_key:
		objective_label.text = "Objetivo: Examina la fotografía en el pasillo de mantenimiento (centro-oeste)."
	else:
		objective_label.text = "Objetivo: Habla con Inés en la sala de espera (suroeste) para conseguir la llave."


func _update_lives_hud() -> void:
	if lives_label == null:
		return
	lives_label.text = "Vidas: %d / %d" % [player_lives, MAX_LIVES]
	if player_lives <= 1:
		lives_label.add_theme_color_override("font_color", Color(0.86, 0.38, 0.38, 1.0))
	else:
		lives_label.add_theme_color_override("font_color", Color(0.788235, 0.682353, 0.486275, 1.0))


func _on_chaser_caught_player(caught_player: Player) -> void:
	_on_chaser_player_caught(caught_player)


func _on_chaser_player_caught(caught_player: Player) -> void:
	if _is_invulnerable:
		return

	player_lives -= 1
	_update_lives_hud()

	var catches: int = int(WorldState.state.get("level2_caught_count", 0)) + 1
	WorldState.state["level2_caught_count"] = catches
	WorldState.time_management["level2_catches"] = catches

	if player_lives > 0:
		if is_instance_valid(caught_player):
			caught_player.global_position = RESPAWN_POSITION
			caught_player.velocity = Vector2.ZERO

		if chaser != null:
			chaser.global_position = Vector2(72, -16)
			chaser.is_distracted = false

		_is_invulnerable = true
		if _invulnerability_tween != null and _invulnerability_tween.is_valid():
			_invulnerability_tween.kill()

		if is_instance_valid(caught_player):
			_invulnerability_tween = create_tween()
			for i in range(4):
				_invulnerability_tween.tween_property(caught_player, "modulate:a", 0.3, 0.18)
				_invulnerability_tween.tween_property(caught_player, "modulate:a", 1.0, 0.18)
			_invulnerability_tween.tween_callback(func() -> void:
				_is_invulnerable = false
				if is_instance_valid(caught_player):
					caught_player.modulate.a = 1.0
			)
		else:
			_is_invulnerable = false

		var notice_text: String = ""
		if player_lives == 1:
			notice_text = "El Desvanecido te alcanzó. Te queda 1 vida."
		else:
			notice_text = "El Desvanecido te alcanzó. Te quedan %d vidas." % player_lives
		_show_notification(notice_text)
	else:
		if chaser != null:
			chaser.set_active_state(false)
			chaser.velocity = Vector2.ZERO

		_show_notification("El Olvido ha borrado tus pasos... Reiniciando la estación")
		get_tree().create_timer(1.5).timeout.connect(_restart_level2_local_state)


func _restart_level2_local_state() -> void:
	var state_keys_to_clear: Array[String] = [
		"samuel_photo_examined",
		"clock_tower_letter_read",
		"has_station_key",
		"station_lever_pulled",
		"waiting_room_page_unlocked",
		"level2_caught_count"
	]
	for key: String in state_keys_to_clear:
		WorldState.state.erase(key)

	var clues_to_clear: Array[String] = [
		"clue_samuel_photo",
		"llave_estacion",
		"carta_abuelo"
	]
	for clue: String in clues_to_clear:
		WorldState.clues_found.erase(clue)

	var memories_to_clear: Array[String] = [
		"Recuerdo de Samuel en el andén",
		"Carta del abuelo en la torre del reloj",
		"Página adicional: Los viajes del abuelo y Samuel en la estación"
	]
	for mem: String in memories_to_clear:
		WorldState.recovered_memories.erase(mem)

	WorldState.important_choices.erase("samuel_memory_focus")
	WorldState.important_choices.erase("level2_distractions_used")
	WorldState.time_management.erase("level2_escape_seconds")
	WorldState.time_management.erase("level2_catches")

	var inspected_to_clear: Array[String] = [
		"waiting_room_photos",
		"waiting_room_schedule",
		"waiting_room_lost_box"
	]
	for insp: String in inspected_to_clear:
		WorldState.inspected_objects.erase(insp)

	get_tree().change_scene_to_file("res://scenes/levels/Level2.tscn")


func _show_notification(message: String) -> void:
	if notification_panel == null or notification_label == null:
		return

	if _notification_tween != null and _notification_tween.is_valid():
		_notification_tween.kill()

	notification_label.text = message
	notification_panel.modulate.a = 0.0
	notification_panel.show()

	_notification_tween = create_tween()
	_notification_tween.tween_property(notification_panel, "modulate:a", 1.0, 0.4)
	_notification_tween.tween_interval(4.2)
	_notification_tween.tween_property(notification_panel, "modulate:a", 0.0, 0.5)
	_notification_tween.tween_callback(notification_panel.hide)


func _on_samuel_photo_near(body: Node2D, is_near: bool) -> void:
	if body is Player:
		_near_samuel_photo = is_near
		_update_all_prompts()


func _on_lamp_near(body: Node2D, is_near: bool) -> void:
	if body is Player:
		_near_lamp = is_near
		_update_all_prompts()


func _on_toolbox_near(body: Node2D, is_near: bool) -> void:
	if body is Player:
		_near_toolbox = is_near
		_update_all_prompts()


func _on_bell_near(body: Node2D, is_near: bool) -> void:
	if body is Player:
		_near_bell = is_near
		_update_all_prompts()


func _on_lever_near(body: Node2D, is_near: bool) -> void:
	if body is Player:
		_near_lever = is_near
		_update_all_prompts()


func _on_tower_box_near(body: Node2D, is_near: bool) -> void:
	if body is Player:
		_near_tower_box = is_near
		_update_all_prompts()


func _update_all_prompts() -> void:
	var can_show: bool = not DialogueManager.is_dialogue_active
	if samuel_photo_prompt != null:
		samuel_photo_prompt.visible = can_show and _near_samuel_photo
	if maintenance_lamp_prompt != null:
		maintenance_lamp_prompt.visible = can_show and _near_lamp
	if toolbox_prompt != null:
		toolbox_prompt.visible = can_show and _near_toolbox
	if station_bell_prompt != null:
		station_bell_prompt.visible = can_show and _near_bell
	if signal_lever_prompt != null:
		signal_lever_prompt.visible = can_show and _near_lever
	if clock_tower_box_prompt != null:
		clock_tower_box_prompt.visible = can_show and _near_tower_box
