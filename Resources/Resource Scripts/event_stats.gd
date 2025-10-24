class_name EventStats
extends Resource

@export var event_name: String
@export var event_flavor_text: String
@export var event_energy_cost: int
@export var event_type: GameEnums.EventStyle
@export var event_severity: GameEnums.EventSeverity

# Event conditions
@export var allowed_days: Array[GameEnums.WeekDay] = []  # Empty means any day
@export var allowed_weather: Array[GameEnums.Weather] = []  # Empty means any weather
@export var min_relationship_required: int = 0
@export var requires_holiday: int = -1  # -1 means no holiday required
@export var weight: int = 1  # Higher weight means more likely to be picked
