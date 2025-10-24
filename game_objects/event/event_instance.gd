class_name EventInstance
extends RefCounted  # Using RefCounted instead of Node since this is just data

var event_stats: EventStats  # The original resource data
var is_completed: bool = false
var player_choices: Array = []  # Store any choices the player made for this event
var result_data: Dictionary = {}  # Store any results/consequences from this event

func _init(stats: EventStats) -> void:
	event_stats = stats
