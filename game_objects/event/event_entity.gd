class_name EventEntity
extends Node

signal integrity_depleted

var integrity: int = 100

func _init(initial_integrity: int = 100):
	self.integrity = initial_integrity

func take_impact(impact_amount: int):
	integrity -= impact_amount
	print("Event took %d impact. Current integrity: %d" % [impact_amount, integrity])
	if integrity <= 0:
		integrity = 0
		emit_signal("integrity_depleted")
