class_name Card
extends Node

@onready var card_image: TextureRect = $TextureRect
@onready var card_name: Label = $State
@onready var card_state_machine: CardStateMachine = $CardStateMachine as CardStateMachine

@export var card_data: CardStats

signal reparent_requested(which_card_ui: Card)

func _ready():
	card_image.texture = card_data.card_texture
	card_name.text = card_data.card_name
	card_state_machine.init(self)

func _input(event: InputEvent) -> void:
	card_state_machine.on_input(event)

func _on_gui_input(event: InputEvent) -> void:
	card_state_machine.on_gui_input(event)

func _on_mouse_entered() -> void:
	card_state_machine.on_mouse_entered()

func _on_mouse_exited() -> void:
	card_state_machine.on_mouse_exited()
