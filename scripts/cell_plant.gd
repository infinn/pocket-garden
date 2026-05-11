class_name PlantCell
extends Area2D

## PlantCell - Represents a single cell in the 17x3 placement grid
##
## Each cell corresponds to one tile where a plant can be placed.
## Handles mouse detection to update GameManager's current cell reference.
## When clicked, triggers plant placement or removal based on the current mode.

## Grid position of this cell (e.g., Vector2i(5, 1) for column 5, row 1)
var cell_position : Vector2i

## Called when mouse enters this cell - updates the GameManager with this cell's position
func _on_mouse_entered() -> void:
	GameManager.update_current_cell(cell_position, self)

## Called when this cell is clicked
## Handles both plant placement (if cursor is showing plant) and plant removal (if shovel is active)
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if GameManager.is_cursor_plant_show:
			GameManager.try_place_plant()
		if GameManager.is_shovel_show:
			GameManager.try_remove_plant()
