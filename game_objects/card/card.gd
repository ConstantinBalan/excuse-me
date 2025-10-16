class_name Card
extends Node

@onready var card_image: TextureRect = $TextureRect
@onready var card_name: Label = $State

@export var card_data: CardStats

signal reparent_requested(which_card_ui: Card)

func _ready():
	card_image.texture = card_data.card_texture
	card_name.text = card_data.card_name
