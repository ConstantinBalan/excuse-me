class_name Card_Played_Calculator
extends Node

@onready var event: EventUI = %EventUI

#Excuse cards are effective against -> Events
#Family Cards -> Family, Friends, Co-workers, Strangers
#Friends Cards -> Family, Strangers
#Co-worker Cards -> Family, Friends
#Goods/Services Cards -> Family, Co-workers
#Stranger/Misc. Cards -> N/A




func _ready() -> void:
	connect_signals()


func connect_signals() -> void:
	GameSignals.card_placed.connect(check_if_event_won)


func check_if_event_won(played_card: Card):
	var base_success : float = 0.2
	var final_success : float = base_success
	var severity_modifier : float
	print("Checking " + played_card.card_name.text + " against " + event.event_title.text)
	
	# Check severity comparison
	severity_modifier = severity_calculator(played_card, event)
	final_success += severity_modifier
	
	# Positive keyword modifier
	for key_word in played_card.card_data.excuse_key_words:
		if key_word in event.current_event.event_stats.event_key_words:
			final_success += 0.05
			
	
	return final_success

func severity_calculator(excuse_sev: Card, event_sev: EventUI) -> float:
	var excuse_severity: GameEnums.Severity  = excuse_sev.card_data.card_excuse_severity
	var event_severity: GameEnums.Severity = event_sev.current_event.event_stats.event_severity
	if event_severity > excuse_severity:
		return -0.10
	if event_severity == excuse_severity:
		return 0.0
	if event_severity < excuse_severity:
		return 0.10
	return 0.0

func category_comparision(excuse_cat: Card, event_cat: EventUI) -> float:
	var excuse_category: GameEnums.Category = excuse_cat.card_data.card_category
	var event_category: GameEnums.Category = event_cat.current_event.event_stats.event_type
	return 0.0
