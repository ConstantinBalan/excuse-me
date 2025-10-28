class_name CardDropArea
extends Area2D

# Reference to the card currently placed in this drop area
var placed_card: Card = null



func place_card(card: Card) -> bool:
	"""Attempts to place a card in this drop area. Returns true if successful."""
	if placed_card != null:
		# Already has a card, reject
		return false
	
	placed_card = card
	GameSignals.card_placed.emit(card)
	return true


func remove_card() -> void:
	"""Removes the currently placed card from this drop area."""
	if placed_card != null:
		var card = placed_card
		placed_card = null
		GameSignals.card_removed.emit(card)


func has_card() -> bool:
	"""Returns true if a card is currently placed in this drop area."""
	return placed_card != null


func get_placed_card() -> Card:
	"""Returns the card currently placed in this drop area, or null if none."""
	return placed_card
