class_name Event
extends Node

var event_name : String
var event_description : String
var event_damage : int
var event_type: GameManager.event_type

func _ready():
	event_type = GameManager.event_type.FAMILY
	pass
