class_name Card_Played_Calculator
extends Node

@onready var event: EventUI = %EventUI

func _ready() -> void:
	connect_signals()


func connect_signals() -> void:
	GameSignals.card_placed.connect(check_if_event_won)


func check_if_event_won(played_card: Card):
	print("Checking " + played_card.card_name.text + " against " + event.event_title.text)
