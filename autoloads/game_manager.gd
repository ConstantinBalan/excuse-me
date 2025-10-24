extends Node

var has_save_game: bool


func _ready() -> void:
	#Check if we have data to load in
	if check_save_game_data():
		has_save_game = true
	else:
		has_save_game = false

func check_save_game_data() -> bool:
	return false
