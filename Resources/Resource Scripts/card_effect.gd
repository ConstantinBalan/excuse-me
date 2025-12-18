class_name CardEffect
extends Resource

func execute(target: EventEntity) -> void:
	# This method is virtual and should be overridden by concrete effects.
	push_error("execute() not implemented in concrete CardEffect class.")
