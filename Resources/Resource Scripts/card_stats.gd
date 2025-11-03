class_name CardStats
extends Resource

enum card_style_type {FRIENDS, FAMILY, WORK}


## The image for the card
@export var card_texture: Texture2D

## The card name
@export var card_name : String

## The card cost is the amount of points that the card will take up in the deck
@export_range(1,10,1) var card_cost : int


## The card flavor text that will show below the card image
@export var card_flavor_text : String

## The main category of the five this card falls under
@export var card_category : GameEnums.Category


@export var card_excuse_severity: GameEnums.Severity

@export var excuse_key_words : Array[String]
