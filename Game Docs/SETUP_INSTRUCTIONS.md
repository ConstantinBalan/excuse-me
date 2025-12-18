# CardDropArea Setup Instructions

## Step 1: Attach the CardDropArea Script

1. Open the scene: `Main Scenes/Apartment/apartment.tscn` in the Godot editor
2. In the Scene tree, select the `CardDropArea` node (it's an Area2D)
3. In the Inspector panel on the right, look for the "Script" section at the top
4. Click the folder icon next to "Script" or drag and drop the script file
5. Navigate to and select: `game_objects/card_drop_area/card_drop_area.gd`
6. Click "Open" to attach the script
7. Save the scene (Ctrl+S or Cmd+S)

## How It Works

Once the script is attached, the CardDropArea will:

- **Only allow one card at a time**: When you drop a card into the area, any previously placed card will automatically return to BASE state
- **Center cards**: Cards dropped in the area will be centered within it
- **Allow removal by clicking**: Click on a RELEASED (placed) card to return it to BASE state and remove it from the drop area

## Features Implemented

1. ✅ Only one card can be placed in the CardDropArea at a time
2. ✅ When a new card is placed, the old card returns to BASE state
3. ✅ Clicking a RELEASED card returns it to BASE state
4. ✅ Cards are centered in the drop area when placed

## Testing

1. Run the scene
2. Drag a card and drop it in the CardDropArea (the area with the image at position ~488, 165)
3. The card should snap to the center and show "RELEASED" state
4. Try dragging another card to the same area - the first card should return to your hand
5. Click on the placed card - it should return to BASE state and go back to your hand
