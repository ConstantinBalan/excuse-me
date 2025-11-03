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
	print("Checking " + played_card.card_name.text + " against " + event.event_title.text)
	
	for key_word in played_card.card_data.excuse_key_words:
		if key_word in event.current_event.event_stats.event_key_words:
			final_success += 0.05
			
	
	return final_success
	
