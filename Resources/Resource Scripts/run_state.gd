class_name RunState
extends Resource

@export var deck: Array[CardStats] = []
@export var hand: Array[CardStats] = []

@export var player_energy: int = 100
@export var turn_energy: int = 3
@export var max_turn_energy: int = 3

@export var current_day: GameEnums.WeekDay = GameEnums.WeekDay.MONDAY
@export var current_week: int = 1
@export var current_day_section: GameEnums.DaySection = GameEnums.DaySection.WORK

@export var completed_events: Array[String] = []
@export var unlocked_cards: Array[String] = []
