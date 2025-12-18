class_name CommandQueue
extends Node

var _queue: Array[Command]
var _is_processing: bool = false

func add_command(command: Command) -> void:
	_queue.append(command)
	if not _is_processing:
		_process_next_command()

func _process_next_command() -> void:
	if _queue.is_empty():
		_is_processing = false
		return
	
	var current_command = _queue.pop_front()
	
	current_command.execute_command()
	
	await _safe_wait(current_command)
	
	_process_next_command()
	
func _safe_wait(command: Command) -> void:
	var timer = get_tree().create_timer(5.0)
	
	while not command.is_finished and timer.time_left > 0:
		await get_tree().process_frame
