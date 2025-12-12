class_name Day_Manager
extends Node

var daily_work_events: Array[EventInstance]
var daily_commute_events: Array[EventInstance]
var daily_home_events: Array[EventInstance]
var current_day: GameEnums.WeekDay
var current_weather: GameEnums.Weather
var current_day_section: GameEnums.DaySection
var all_event_resources: Array[EventStats] = [] #This holds all of the event data that is pre-loaded at the start of each day
var week_number: int

@onready var event_ui: EventUI = %EventUI  # Reference to event UI scene
@onready var next_event_button : Button = %NextEventButton
@onready var current_day_label: Label = %CurrentDay
@onready var current_week_label: Label = %CurrentWeek
@onready var player_energy_label: Label = %PlayerEnergy
@onready var background_image: Sprite2D = %Apartment_Background


@onready var player : Player = %Player

signal day_completed
signal week_completed
#Splitting up day into work,commute,home
signal daily_work_completed
signal daily_commute_completed
signal daily_home_completed

signal load_next_event

func _init():
	_preload_event_resources()
	if not all_event_resources.is_empty():
		print("Successfully loaded resources: " + str(all_event_resources))
		
		
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
		player_energy_label.text = "Player Energy: " + str(player.player_energy)
		initialize_new_week()


func connect_signals():
	load_next_event.connect(display_next_event)
	daily_work_completed.connect(_on_work_section_completed)
	daily_commute_completed.connect(_on_commute_section_completed)
	daily_home_completed.connect(_on_home_section_completed)
	week_completed.connect(initialize_new_week)

func initialize_new_week():
	daily_work_events = []
	daily_commute_events = []
	daily_home_events = []
	#Set the day to Monday
	current_day = GameEnums.WeekDay.MONDAY
	current_day_label.text = "Current Day: " + map_current_day_enum_to_string(current_day)
	week_number += 1
	current_week_label.text = "Current Week: " + str(week_number)
	#Get a random weather for Monday
	current_weather = randi() % GameEnums.Weather.size() as GameEnums.Weather
	
	# Start with the Work section of the day
	_generate_and_start_day_section(GameEnums.DaySection.WORK)

func _generate_and_start_day_section(day_section: GameEnums.DaySection) -> void:
	current_day_section = day_section
	
	match day_section:
		GameEnums.DaySection.WORK:
			_generate_events_for_section(daily_work_events, day_section)
			background_image.texture = load("res://assets/Background_Images/Office.png")
		GameEnums.DaySection.COMMUTE:
			_generate_events_for_section(daily_commute_events, day_section)
			background_image.texture = load("res://assets/Background_Images/Commute.jpg")
		GameEnums.DaySection.HOME:
			_generate_events_for_section(daily_home_events, day_section)
			background_image.texture = load("res://assets/Background_Images/Home.jpeg")
	
	# Display the first event of this section
	display_next_event()

func _generate_events_for_section(events_array: Array[EventInstance], day_section: GameEnums.DaySection) -> void:
	events_array.clear()
	var num_events = randi() % 3 + 1  # Generate 1-3 events
	
	var available_events = load_filtered_events(current_day, current_weather, day_section)
	print("Generated %d events for %s section with %d available events" % [num_events, GameEnums.DaySection.keys()[day_section], available_events.size()])
	
	for i in range(num_events):
		var selected_event = select_weighted_random_event(available_events)
		if selected_event:
			var new_event = EventInstance.new(selected_event)
			events_array.append(new_event)



func _preload_event_resources() -> void:
	# Load all event resources at startup
	# Gotta think if this is necessary or useful. I think it is, but LOL who knows
	all_event_resources.clear()
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
					all_event_resources.append(event_res)

func load_filtered_events(day_of_week: GameEnums.WeekDay, weather: GameEnums.Weather, day_section: GameEnums.DaySection) -> Array:
	var filtered_events: Array = []
	
	# Filter from preloaded resources
	for event_res in all_event_resources:
		if is_event_valid(event_res, day_of_week, weather, day_section):
			filtered_events.append(event_res)
	
	return filtered_events

func is_event_valid(event: EventStats, day: GameEnums.WeekDay, weather: GameEnums.Weather, day_section: GameEnums.DaySection) -> bool:
	# Check if event can occur on this day
	if not event.allowed_days.is_empty() and not event.allowed_days.has(day):
		return false
		
	# Check if event can occur in this weather
	if not event.allowed_weather.is_empty() and not event.allowed_weather.has(weather):
		return false
		
	if not event.allowed_day_sections.is_empty() and not event.allowed_day_sections.has(day_section):
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
	var current_events: Array[EventInstance] = []
	
	match current_day_section:
		GameEnums.DaySection.WORK:
			current_events = daily_work_events
		GameEnums.DaySection.COMMUTE:
			current_events = daily_commute_events
		GameEnums.DaySection.HOME:
			current_events = daily_home_events
	
	if current_events.is_empty():
		print("Out of events for the %s section" % GameEnums.DaySection.keys()[current_day_section])
		_on_section_completed()
		return
		
	var next_event = current_events.pop_front()
	event_ui.display_event(next_event)

func _on_event_completed(_result: Dictionary) -> void:
	# Store result if needed
	display_next_event()

func _on_section_completed() -> void:
	match current_day_section:
		GameEnums.DaySection.WORK:
			print("Work section completed")
			daily_work_completed.emit()
		GameEnums.DaySection.COMMUTE:
			print("Commute section completed")
			daily_commute_completed.emit()
		GameEnums.DaySection.HOME:
			print("Home section completed")
			daily_home_completed.emit()

func _on_work_section_completed() -> void:
	_generate_and_start_day_section(GameEnums.DaySection.COMMUTE)

func _on_commute_section_completed() -> void:
	_generate_and_start_day_section(GameEnums.DaySection.HOME)

func _on_home_section_completed() -> void:
	_on_day_completed()

func _on_day_completed() -> void:
	current_day = (current_day + 1) % GameEnums.WeekDay.size() as GameEnums.WeekDay
	print("Current day in the day_completed function: " + map_current_day_enum_to_string(current_day))
	update_current_day_label()
	if current_day == GameEnums.WeekDay.MONDAY:
		emit_signal("week_completed")
		print("Week completed")
	else:
		current_weather = randi() % GameEnums.Weather.size() as GameEnums.Weather
		# Start next day with the work section
		_generate_and_start_day_section(GameEnums.DaySection.WORK)
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

func update_current_day_label() -> void:
	current_day_label.text = "Current Day: " + map_current_day_enum_to_string(current_day)
	
func update_player_energy_label(updated_energy: int) -> void:
	player_energy_label.text = "Player Energy: " + str(updated_energy)
	
