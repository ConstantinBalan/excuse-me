extends CardState

var played: bool


func enter() -> void:
	#card_ui.card_color.color = Color.DARK_VIOLET
	#card_ui.card_name.text = "RELEASED"
	played = false
	
	if not card_ui.drop_area == null:
		# Check if the drop area is a CardDropArea and if it can accept a card
		if card_ui.drop_area is CardDropArea:
			var drop_area_script = card_ui.drop_area as CardDropArea
			
			# If there's already a card in the drop area, return it to BASE
			if drop_area_script.has_card():
				var existing_card = drop_area_script.get_placed_card()
				if existing_card and existing_card != card_ui:
					# Remove the existing card and return it to BASE state
					print("Existing Card Name: ",existing_card.card_name)
					print("Card_UI Card Name: ",card_ui.card_name)
					drop_area_script.remove_card()
					if existing_card.card_state_machine:
						existing_card.card_state_machine.change_state(CardState.State.BASE)
			
			# Try to place this card in the drop area
			if drop_area_script.place_card(card_ui):
				played = true
				print("played card for", card_ui.drop_area)
				# Center the card in the drop area
				center_card_in_drop_area()
			else:
				# Failed to place, return to BASE
				transition_requested.emit(self, CardState.State.BASE)
		else:
			# Not a CardDropArea, just play it
			played = true
			print("played card for", card_ui.drop_area)
			center_card_in_drop_area()

func exit() -> void:
	# When leaving RELEASED state, remove card from drop area if it was placed
	if played and card_ui.drop_area and card_ui.drop_area is CardDropArea:
		var drop_area_script = card_ui.drop_area as CardDropArea
		if drop_area_script.get_placed_card() == card_ui:
			drop_area_script.remove_card()

func center_card_in_drop_area() -> void:
	if card_ui.drop_area:
		# Get the center position of the drop area from its CollisionShape2D
		var collision_shape = card_ui.drop_area.get_node("CollisionShape2D")
		if collision_shape:
			var drop_area_center = collision_shape.global_position
			# Center the card by offsetting by half its size
			var card_size = card_ui.size
			card_ui.global_position = drop_area_center - (card_size / 2.0)

func on_gui_input(event: InputEvent) -> void:
	# Allow clicking the RELEASED card to return it to BASE state
	if played and event.is_action_pressed("left_mouse"):
		transition_requested.emit(self, CardState.State.BASE)
		
func on_input(event: InputEvent) -> void:
	if played:
		return
		
	transition_requested.emit(self, CardState.State.BASE)
