extends Node

signal notebook_state_changed(is_active: bool)

var state: Dictionary = {}
var is_notebook_active: bool = false


func toggle_notebook() -> void:
	is_notebook_active = not is_notebook_active
	notebook_state_changed.emit(is_notebook_active)
