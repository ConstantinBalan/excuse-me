class_name Card
extends Node

@onready var card_image: TextureRect = %CardImage
@onready var card_name: Label = %CardName
@onready var card_color : ColorRect = $Color
@onready var card_cost: Label = %CardCost
@onready var card_flavor_text: Label = %CardFlavorText

@onready var drop_point_detector: Area2D = $DropPointDetector
@onready var card_state_machine: CardStateMachine = $CardStateMachine as CardStateMachine
@onready var drop_area: Area2D = null

@export var card_data: CardStats

signal reparent_requested(which_card_ui: Card)


func _ready():
	card_image.texture = card_data.card_texture
	card_name.text = card_data.card_name
	card_cost.text = str(card_data.card_cost)
	card_flavor_text.text = card_data.card_flavor_text
	card_state_machine.init(self)
	
func _input(event: InputEvent) -> void:
	card_state_machine.on_input(event)

func _on_gui_input(event: InputEvent) -> void:
	card_state_machine.on_gui_input(event)

func _on_mouse_entered() -> void:
	card_state_machine.on_mouse_entered()

func _on_mouse_exited() -> void:
	card_state_machine.on_mouse_exited()

func _on_drop_point_detector_area_entered(area: Area2D) -> void:
	drop_area = area

func _on_drop_point_detector_area_exited(area: Area2D) -> void:
	drop_area = null
