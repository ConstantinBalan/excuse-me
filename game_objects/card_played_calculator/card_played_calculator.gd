class_name Card_Played_Calculator
extends Node

@onready var event: EventUI = %EventUI

func _ready() -> void:
	connect_signals()

func connect_signals() -> void:
	GameSignals.card_placed.connect(on_card_placed)

func on_card_placed(played_card: Card) -> void:
	if not event.current_event or not event.current_event.event_entity:
		printerr("Cannot apply card effects: Current event or event_entity is null!")
		return

	if not played_card.card_data or not "effects" in played_card.card_data:
		printerr("Cannot apply card effects: Card data or effects array is missing!")
		return

	var target_entity = event.current_event.event_entity
	
	print("Applying effects from " + played_card.card_name.text + " to " + event.event_title.text)

	for effect in played_card.card_data.effects:
		if effect is CardEffect:
			effect.execute(target_entity)
			# Adding a small delay for visual feedback between effects
			await get_tree().create_timer(0.5).timeout
		else:
			push_warning("Item in effects array is not a valid CardEffect resource.")
			
	print("All effects applied.")
