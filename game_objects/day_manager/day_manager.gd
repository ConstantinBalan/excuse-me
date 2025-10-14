class_name Day_Manager
extends Node

var events: Array[Event]
var current_day: Current_Weekday
enum Current_Weekday {MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY}

func _init():
	pass

func _ready():
	events = []
	current_day = Current_Weekday.MONDAY
	generate_events_for_day(current_day, "Rainy")
	play_event(events)

func generate_events_for_day(day_of_week: Current_Weekday,day_type: String) -> void:
	var events_for_day = randi() % 3
	
	for event in events_for_day:
		var event_data: Event = generate_event_data(day_of_week, day_type, 5)
		events.append(event_data)

func generate_event_data(day_of_week: Current_Weekday, day_type: String, day_karma: int):
	match day_of_week:
		"Monday":
			print("It's Monday")
			match day_type:
				"Rainy":
					print("It's Rainy")
				"Windy":
					print("It's Windy")
		"Tuesday":
			print("It's Monday")
		"Wednesday":
			print("It's Monday")
		"Thursday":
			print("It's Monday")
		"Friday":
			print("It's Monday")
			
func play_event(events: Array[Event]):
	pass
