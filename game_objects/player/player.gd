class_name Player
extends Node

enum Player_Class {AVOIDER, OVERSHARER, APOLOGIZER, DOOMSCROLLER, FLAKE}

@export_category("Player Stats")
var player_name : String
var player_xp : float
var player_energy: int

@export_category("Player Card Info")
var card_library : Card_Library
var card_deck : Deck


func _ready():
	if GameManager.has_save_game:
		#Existing Save Game Path
		#load player card library
		#set player name
		#set player card deck
		#set player xp and energy
		pass
	else:
		#New Game Path
		#Initialize player stats
		player_energy = 50
		player_name = ""
		

func load_deck():
	pass

func set_player_stats():
	pass
