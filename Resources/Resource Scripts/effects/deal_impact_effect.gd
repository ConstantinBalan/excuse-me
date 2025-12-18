class_name DealImpactEffect
extends CardEffect

@export var amount: int = 0

func execute(target: EventEntity) -> void:
	if target:
		target.take_impact(amount)
	else:
		push_error("DealImpactEffect requires a valid EventEntity target.")
