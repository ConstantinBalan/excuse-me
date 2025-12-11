class_name EventStats
extends Resource

@export var event_name: String
@export var event_flavor_text: String
@export_range(1,20,1) var event_energy_cost: int
@export var event_type: GameEnums.Category
@export var event_severity: GameEnums.Severity
@export var effective_keywords: Array[String]

# Event conditions
@export var allowed_days: Array[GameEnums.WeekDay] = []  # Empty means any day
@export var allowed_weather: Array[GameEnums.Weather] = []  # Empty means any weather
@export var allowed_day_sections: Array[GameEnums.DaySection] = [] # Empty means any day section
@export var min_relationship_required: int = 0
@export var requires_holiday: int = -1  # -1 means no holiday required
@export var weight: int = 1  # Higher weight means more likely to be picked
