class_name Day_Manager
extends Node

var daily_events: Array[EventInstance]  # Events for the current day
var current_day: GameEnums.WeekDay
var current_weather: GameEnums.Weather
var all_event_resouces: Array[EventStats] = []
var week_number: int

@onready var event_ui: EventUI = %EventUI  # Reference to your event UI scene
@onready var next_event_button : Button = %NextEventButton
@onready var current_day_label: Label = %CurrentDay
@onready var current_week_label: Label = %CurrentWeek

signal day_completed
signal week_completed
signal load_next_event

func _init():
	_preload_event_resources()
	if not all_event_resouces.is_empty():
		print("Successfully loaded resources: " + str(all_event_resouces))
		
		
func _ready():
	connect_signals()
	if GameManager.has_save_game:
		#load save game events
		#set current day
		#play next events
		pass
	else:
		#Start new week
		week_number = 0
		initialize_new_week()


func connect_signals():
	load_next_event.connect(display_next_event)
	day_completed.connect(update_current_day_label)
	week_completed.connect(initialize_new_week)

func initialize_new_week():
		daily_events = []
		#Set the day to Monday
		current_day = GameEnums.WeekDay.MONDAY
		current_day_label.text = "Current Day: " + map_current_day_enum_to_string(current_day)
		week_number += 1
		current_week_label.text = "Current Week: " + str(week_number)
		#Get a random weather for Monday
		current_weather = randi() % 6 as GameEnums.Weather
		generate_events_for_day(current_day, current_weather)

func generate_events_for_day(day_of_week: GameEnums.WeekDay, day_weather: GameEnums.Weather) -> void:
	daily_events.clear()
	
	var num_events = randi() % 3 + 1  # Generate 1-3 events
	print("Today's weather is: " + str(day_weather))
	print("Number of events for the day are: " + str(num_events))
	
	var available_events = load_filtered_events(day_of_week, day_weather)
	print(available_events)
	
	for events_for_today in range(num_events):
		var selected_event = select_weighted_random_event(available_events)
		if selected_event:
			var new_event = EventInstance.new(selected_event)
			daily_events.append(new_event)
	
	if not daily_events.is_empty():
		display_next_event()

func _preload_event_resources() -> void:
	# Load all event resources at startup
	all_event_resouces.clear()
	var events_path = "res://Resources/event_types/"
	var events_sub_folders : Array = ["Family Events/", "Friend Events/", "Misc Events/", "Work Events/"]

	
	# Get all .tres files in the events directory
	var resource_paths = []
	
	# Load each resource
	for sub_folder in events_sub_folders:
		resource_paths = ResourceLoader.list_directory(str(events_path) + str(sub_folder))
		for path in resource_paths:
			if path.ends_with(".tres"):
				var event_res = ResourceLoader.load(events_path + sub_folder + path) as EventStats
				if event_res:
					all_event_resouces.append(event_res)

func load_filtered_events(day_of_week: GameEnums.WeekDay, weather: GameEnums.Weather) -> Array:
	var filtered_events: Array = []
	
	# Filter from preloaded resources
	for event_res in all_event_resouces:
		if is_event_valid(event_res, day_of_week, weather):
			filtered_events.append(event_res)
	
	return filtered_events

func is_event_valid(event: EventStats, day: GameEnums.WeekDay, weather: GameEnums.Weather) -> bool:
	# Check if event can occur on this day
	if not event.allowed_days.is_empty() and not event.allowed_days.has(day):
		return false
		
	# Check if event can occur in this weather
	if not event.allowed_weather.is_empty() and not event.allowed_weather.has(weather):
		return false
		
	# Add more conditions here as needed (e.g., holiday checks, relationship checks)
	
	return true

func select_weighted_random_event(events: Array) -> EventStats:
	if events.is_empty():
		print("Events for the day were empty")
		return null
		
	var total_weight = 0
	for event in events:
		total_weight += event.weight
		
	var random_value = randi() % total_weight
	var current_weight = 0
	
	for event in events:
		current_weight += event.weight
		if random_value < current_weight:
			return event
			
	return events[0]  # Fallback in case of rounding errors

func display_next_event() -> void:
	if daily_events.is_empty():
		print("Out of events for the day")
		_on_day_completed()
		return
		
	var next_event = daily_events.pop_front()
	event_ui.display_event(next_event)

func _on_event_completed(result: Dictionary) -> void:
	# Store result if needed
	if not daily_events.is_empty():
		display_next_event()
	else:
		_on_day_completed()

func _on_day_completed() -> void:
	current_day = (current_day + 1) % GameEnums.WeekDay.size()
	print("Current day in the day_completed function: " + map_current_day_enum_to_string(current_day))
	if current_day == GameEnums.WeekDay.MONDAY:
		emit_signal("week_completed")
		print("Week completed")
	else:
		current_weather = randi() % GameEnums.Weather.size()
		generate_events_for_day(current_day, current_weather)
		emit_signal("day_completed")

func _on_next_event_button_pressed() -> void:
	print("Loading next event")
	load_next_event.emit()

func map_current_day_enum_to_string(current_day_enum_val: GameEnums.WeekDay) -> String:
	match current_day_enum_val:
		0:
			return "Monday"
		1:
			return "Tuesday"
		2:
			return "Wednesday"
		3:
			return "Thursday"
		4:
			return "Friday"
		_:
			return "Oops, you missed mapping a day"

func update_current_day_label():
	current_day_label.text = "Current Day: " + map_current_day_enum_to_string(current_day)
