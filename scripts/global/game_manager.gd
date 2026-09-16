extends Node2D

## GameManager - Core game state and plant placement controller
##
## This is the third global script to run and acts as the central controller for plant placement mechanics.
## 
## Responsibilities:
##   - Manages plant placement and removal from the game grid
##   - Tracks planted plants and their positions
##   - Handles cursor interactions (plant cursor and shovel cursor)
##   - Validates grid cells and communicates with the game world
##   - Emits signals when plants are placed or deleted
##
## The flow is:
## 1. Player clicks a plant card → select_plant() is called
## 2. Cursor shows plant icon, grid cells become visible
## 3. Player moves cursor over cells → update_current_cell() updates the current cell
## 4. Player clicks a cell → try_place_plant() or try_remove_plant() is called
## 5. HUD and world are updated accordingly

var current_world : World
var cursor_plant : CursorPlant
var cursor_shovel : CursorShovel
var is_valid_cell : bool = false
var is_cursor_plant_show : bool = false
var is_shovel_show : bool = false
var plants_placed : Dictionary = {}
var selected_panel : PanelPlant
var current_position : Vector2i
var current_cell : PlantCell
var hud : HUD

## Emitted when a plant is successfully placed on the grid
## Argument: the name of the plant placed (e.g., "sunflower")
signal plant_placed(name)

## Emitted when a plant is removed from the grid
## Argument: the name of the plant removed
signal plant_delete(name)

func _physics_process(_delta: float) -> void:
	if cursor_plant != null and is_cursor_plant_show:
		cursor_plant.global_position = get_global_mouse_position()
	if cursor_shovel != null and is_shovel_show:
		cursor_shovel.global_position = get_global_mouse_position()

## Called when the player selects a plant from the plant panel
## Shows the plant cursor and grid cells if the player has enough sun
func select_plant(panel_plant : PanelPlant):
	if Global.sun_amount_player < panel_plant.sun_cost:
		return
	
	selected_panel = panel_plant
	
	# show cursor with seed plant
	if !is_cursor_plant_show:
		is_cursor_plant_show = true
		cursor_plant.update_visual(selected_panel)
		current_world.show_cell(true)
		hud.show_cancel_button(true)

## Updates the current cell when the cursor enters a grid cell
## Also validates whether the cell is empty (valid for placement)
func update_current_cell(postition : Vector2i, cell : PlantCell):
	cursor_plant.set_valid_cell(!plants_placed.has(postition))
	current_position = postition
	current_cell = cell

## Attempts to place the selected plant at the current cell position
## Deducts sun cost and emits the plant_placed signal
func try_place_plant():
	if selected_panel and not plants_placed.has(current_position):
		var new_plant = selected_panel.plant_setup.instantiate()
		current_world.plants.add_child(new_plant)
		
		new_plant.global_position = current_cell.global_position
		plants_placed[current_position] = new_plant
		
		new_plant.cell_plant = current_position
		
		Global.subtract_sun(selected_panel.sun_cost)
		plant_placed.emit(selected_panel.plant_name)
		
		# reset variables
		selected_panel = null
		current_cell = null
		is_cursor_plant_show = false
		current_world.show_cell(false)
		cursor_plant.update_visual(null)
		
		hud.show_cancel_button(false)

func delete_plant(place, p_name):
	plant_delete.emit(p_name)
	plants_placed.erase(place)

## Cancels the current plant placement or shovel mode
## Hides the cursor and grid cells
func cancel_place():
	# reset variables
	selected_panel = null
	current_cell = null
	is_cursor_plant_show = false
	current_world.show_cell(false)
	cursor_plant.update_visual(null)
	
	hud.show_cancel_button(false)

## Attempts to remove a plant at the current cell position
## Called when using the shovel tool
func try_remove_plant():
	if plants_placed.has(current_position):
		var plant_to_delete = plants_placed[current_position]
		
		plant_to_delete.queue_free()
		delete_plant(current_position, plant_to_delete.plant_name)
		
		cursor_shovel.position = Vector2(35, 27)
		
		current_cell = null
		is_shovel_show = false
		current_world.show_cell(false)

## Resets the game state when reloading the World1 scene
## Clears selected plants, cells, cursor states, and resets player sun to 0
func reset_scene():
	selected_panel = null
	current_cell = null
	current_position = Vector2(0,0)
	is_cursor_plant_show = false
	is_shovel_show = false
	
	current_world.show_cell(false)
	cursor_plant.update_visual(null)
	
	hud.show_cancel_button(false)
	Global.sun_amount_player = 0
	
	plants_placed = {}
