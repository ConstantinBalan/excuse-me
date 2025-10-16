class_name CardStats
extends Resource

## The image for the card
@export var card_texture: Texture2D

## The card name
@export var card_name : String

## The card cost is the amount of points that the card will take up in the deck
@export_range(1,10,1) var card_cost : int


## The card type determines which type of event the card is most effective against
@export var card_type : CardType.card_type
