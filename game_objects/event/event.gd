class_name EventUI
extends Control

@onready var event_title = %EventTitle
@onready var event_energy = %EventEnergy
@onready var event_flavor_text = %FlavorText

signal event_completed(result: Dictionary)

var current_event: EventInstance

func _ready():
	self.hide()  # Hide by default until an event is displayed

func display_event(event_instance: EventInstance) -> void:
	current_event = event_instance
	
	# Update UI elements
	event_title.text = current_event.event_stats.event_name
	event_energy.text = str(current_event.event_stats.event_energy_cost)
	event_flavor_text.text = current_event.event_stats.event_flavor_text
	
	show()

func hide_event() -> void:
	hide()
	current_event = null
