class_name Level1
extends Node2D

var _notification_tween: Tween = null

@onready var npc_lucia: NPC = $NPC_Lucia
@onready var npc_elias: NPC = $NPC_Elias
@onready var npc_marta: NPC = $NPC_Marta

@onready var objective_panel: PanelContainer = $NotificationLayer/ObjectivePanel
@onready var objective_label: Label = $NotificationLayer/ObjectivePanel/MarginContainer/ObjectiveLabel
@onready var notification_panel: PanelContainer = $NotificationLayer/NotificationPanel
@onready var notification_label: Label = $NotificationLayer/NotificationPanel/MarginContainer/NotificationLabel


func _ready() -> void:
	WorldState.current_level = "res://scenes/levels/Level1.tscn"
	if notification_panel != null:
		notification_panel.hide()
		notification_panel.modulate.a = 0.0

	WorldState.status_notification_requested.connect(_on_status_notification_requested)
	DialogueManager.dialogue_ended.connect(_update_npc_dialogues)
	DialogueManager.dialogue_ended.connect(_update_objective_hud)
	WorldState.clue_registered.connect(_on_clue_registered)
	WorldState.memory_reconstructed.connect(_on_memory_reconstructed)

	_update_npc_dialogues()
	_update_objective_hud()


func _on_clue_registered(_clue_id: String, _total: int) -> void:
	_update_npc_dialogues()
	_update_objective_hud()


func _on_memory_reconstructed(_memory_id: String) -> void:
	_update_npc_dialogues()
	_update_objective_hud()


func _update_npc_dialogues() -> void:
	var reconstructed: bool = bool(WorldState.state.get("lucia_tomas_reconstructed", false))
	var has_all_clues: bool = WorldState.has_all_level1_clues()
	var talked_lucia: bool = bool(WorldState.state.get("talked_lucia", false))
	var talked_elias: bool = bool(WorldState.state.get("talked_elias", false))
	var talked_marta: bool = bool(WorldState.state.get("talked_marta", false))
	var has_flower: bool = WorldState.clues_found.has("clue_paper_flower")

	# Lucía:
	# Si ya hablaste con ella (talked_lucia) y aún no tienes las 3 pistas, usa nodo de seguimiento
	# (lucia_seguimiento) que reaccione si ya conoces el nombre de Tomás (talked_elias) o ya tienes la flor de papel (clue_paper_flower).
	# Con 3 pistas -> lucia_reconstruccion. Tras completarla -> lucia_post_reconstruccion.
	if npc_lucia != null:
		if reconstructed:
			npc_lucia.dialogue_id = "lucia_post_reconstruccion"
		elif has_all_clues:
			npc_lucia.dialogue_id = "lucia_reconstruccion"
		elif talked_lucia:
			if has_flower:
				npc_lucia.dialogue_id = "lucia_seguimiento_flor"
			elif talked_elias:
				npc_lucia.dialogue_id = "lucia_seguimiento_tomas"
			else:
				npc_lucia.dialogue_id = "lucia_seguimiento"
		else:
			npc_lucia.dialogue_id = "lucia_inicio"

	# Don Elías:
	# Si ya hablaste con él (talked_elias), pasa a nodo de seguimiento (elias_seguimiento o elias_con_flor si ya
	# obtuviste clue_paper_flower con Marta) y a elias_post_reconstruccion tras restaurar el recuerdo.
	if npc_elias != null:
		if reconstructed:
			npc_elias.dialogue_id = "elias_post_reconstruccion"
		elif talked_elias:
			if has_flower:
				npc_elias.dialogue_id = "elias_con_flor"
			else:
				npc_elias.dialogue_id = "elias_seguimiento"
		else:
			npc_elias.dialogue_id = "elias_inicio"

	# Marta:
	# Si ya te entregó la flor (talked_marta / clue_paper_flower), pasa a marta_seguimiento
	# (mencionando a Tomás si ya hablaste con Don Elías) y a marta_post_reconstruccion tras restaurar el recuerdo.
	if npc_marta != null:
		if reconstructed:
			npc_marta.dialogue_id = "marta_post_reconstruccion"
		elif talked_marta or has_flower:
			if talked_elias:
				npc_marta.dialogue_id = "marta_seguimiento_tomas"
			else:
				npc_marta.dialogue_id = "marta_seguimiento"
		else:
			npc_marta.dialogue_id = "marta_inicio"


func _update_objective_hud() -> void:
	if objective_label == null:
		return

	var reconstructed: bool = bool(WorldState.state.get("lucia_tomas_reconstructed", false))
	var has_all_clues: bool = WorldState.has_all_level1_clues()
	var talked_lucia: bool = bool(WorldState.state.get("talked_lucia", false))
	var talked_elias: bool = bool(WorldState.state.get("talked_elias", false))
	var talked_marta: bool = bool(WorldState.state.get("talked_marta", false))

	if reconstructed:
		objective_label.text = "Objetivo: Cruza el antiguo puente hacia el norte rumbo a la Estación."
	elif has_all_clues:
		objective_label.text = "Objetivo: Vuelve con Lucía en la plaza para reconstruir el recuerdo."
	elif not talked_lucia:
		objective_label.text = "Objetivo: Habla con Lucía junto a la fuente en la plaza central."
	elif not talked_elias or not talked_marta:
		objective_label.text = "Objetivo: Conversa con Don Elías (reloj) y Marta (floristería al oeste)."
	else:
		var clues_count: int = 0
		for req_clue: String in WorldState.LEVEL1_REQUIRED_CLUES:
			if WorldState.clues_found.has(req_clue):
				clues_count += 1
		objective_label.text = "Objetivo: Reúne las pistas con el Cuaderno [Q] — Panadería (este) y Puente (norte) · Pistas: %d/3." % clues_count


func _on_status_notification_requested(message: String) -> void:
	if notification_panel == null or notification_label == null:
		return

	if _notification_tween != null and _notification_tween.is_valid():
		_notification_tween.kill()

	notification_label.text = message
	notification_panel.modulate.a = 0.0
	notification_panel.show()

	_notification_tween = create_tween()
	_notification_tween.tween_property(notification_panel, "modulate:a", 1.0, 0.5)
	_notification_tween.tween_interval(4.5)
	_notification_tween.tween_property(notification_panel, "modulate:a", 0.0, 0.6)
	_notification_tween.tween_callback(notification_panel.hide)
