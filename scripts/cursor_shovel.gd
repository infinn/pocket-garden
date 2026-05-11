class_name CursorShovel
extends Node2D

## CursorShovel - Visual cursor showing the shovel for removing plants
##
## Displays the shovel icon at the mouse position during plant removal mode.
## Shows visual feedback (grey highlight) when hovering over a cell without a plant.

@onready var sprite: Sprite2D = $Sprite2D

## Changes the cursor color to indicate if there's a plant to remove
## Normal (white) = plant exists, Grey (dim) = no plant at this cell
func set_valid_cell(is_valid : bool):
	if is_valid:
		sprite.self_modulate = Color(1.0, 1.0, 1.0, 1)
	else:
		sprite.self_modulate = Color(0.632, 0.632, 0.632, 0.4)
