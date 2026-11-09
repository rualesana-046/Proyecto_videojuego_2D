extends Node

signal notebook_state_changed(is_active: bool)
signal wax_fragment_collected(total: int)

var state: Dictionary = {}
var is_notebook_active: bool = false
var wax_fragments: int = 0


func toggle_notebook() -> void:
	is_notebook_active = not is_notebook_active
	notebook_state_changed.emit(is_notebook_active)


func add_wax_fragment() -> void:
	wax_fragments += 1
	wax_fragment_collected.emit(wax_fragments)


func reset_wax_fragments() -> void:
	wax_fragments = 0
	wax_fragment_collected.emit(wax_fragments)
