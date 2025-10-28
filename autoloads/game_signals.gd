extends Node

# Signal emitted when a card is placed or removed
signal card_placed(card: Card)
signal card_removed(card: Card)

signal event_played_status(energy_lost: int)
