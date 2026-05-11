class_name CursorPlant
extends Node2D

## CursorPlant - Visual cursor that shows the selected plant while placing
##
## Displays the plant texture at the mouse position during placement mode.
## Shows visual feedback (red highlight) when the cell is invalid for placement.

@onready var sprite: Sprite2D = $Sprite2D

## Updates the sprite texture to match the selected plant
## Pass null to hide the cursor
func update_visual(panel_plant : PanelPlant):
	if panel_plant == null:
		sprite.texture = null
		return
	sprite.texture = panel_plant.texture

## Changes the cursor color to indicate if the current cell is valid for placement
## Green (normal) = valid, Red (dim) = invalid (cell already occupied)
func set_valid_cell(is_valid : bool):
	if is_valid:
		sprite.self_modulate = Color(1.0, 1.0, 1.0, 1)
	else:
		sprite.self_modulate = Color(0.663, 0.0, 0.0, 0.4)
