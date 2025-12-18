class_name Command
extends RefCounted

signal finished()

var is_finished: bool = false

func execute_command() -> void:
	_execute_logic()
	_execute_visuals()

func _execute_logic() -> void:
	pass
	
func _execute_visuals() -> void:
	call_deferred("emit_signal", "finished")
