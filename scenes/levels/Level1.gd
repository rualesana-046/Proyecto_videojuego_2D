class_name Level1
extends Node2D

var _notification_tween: Tween = null

@onready var notification_panel: PanelContainer = $NotificationLayer/NotificationPanel
@onready var notification_label: Label = $NotificationLayer/NotificationPanel/MarginContainer/NotificationLabel


func _ready() -> void:
	WorldState.current_level = "res://scenes/levels/Level1.tscn"
	if notification_panel != null:
		notification_panel.hide()
		notification_panel.modulate.a = 0.0

	WorldState.status_notification_requested.connect(_on_status_notification_requested)


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
