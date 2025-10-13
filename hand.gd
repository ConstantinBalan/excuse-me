extends Node2D

const CARD = preload("res://game_objects/card/card_ui.tscn")
@export var curve: Curve
@export var height_curve : Curve
@onready var hand = %Hand

func _ready():
	add_5_cards()

func add_5_cards() -> void:
	for _x in 5:
		var card = CARD.instantiate()
		add_child(card)
	
	for card in hand.get_children():
		var hand_ratio = 0.5
		
		if get_child_count() > 1:
			hand_ratio = float(card.get_index())/ float(hand.get_child_count())
		
		var destination = hand.global_position
		destination.x += curve.sample(hand_ratio) * 2.0
