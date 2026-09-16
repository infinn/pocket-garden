class_name World
extends Node2D

## World - Main game level controller and wave spawning manager
##
## Manages the game world for each level, including:
##   - Grid cell creation and visibility
##   - Plant and zombie spawning
##   - Wave progression and zombie spawn timing
##   - HUD updates (wave counter, progress bar)
##
## Wave System:
## - Waves are defined in WaveData (scripts/global/wave_data.gd)
## - Each wave has a list of zombies with spawn probabilities and respawn timers
## - timer_spawn triggers the next wave after a delay
## - timer_zombie spawns individual zombies using weighted random selection
## - Wave progress is displayed in a progress bar

@onready var cell: Node2D = $cell
@onready var cursor_plant: Node2D = $cursor_plant
@onready var plants: Node2D = $plants
@onready var line: Node2D = $line
@onready var timer_spawn: Timer = $Timer_spawn
@onready var timer_zombie: Timer = $Timer_zombie
@onready var wave_label: Label = $HUDRigth/WaveLabel
@onready var wave_progress_bar: ProgressBar = $HUDRigth/WaveProgressBar
@onready var start_zombie: AudioStreamPlayer2D = $StartZombie
@onready var cursor_shovel: CursorShovel = $HUDRigth/CursorShovel
@onready var shovel_remove: AudioStreamPlayer2D = $ShovelRemove
@onready var shovel_click: AudioStreamPlayer2D = $ShovelClick
@onready var money_label: Label = $HUDRigth/MoneyLabel


## Current wave index in the wave progression
var current_wave : int = -1

## Initializes the game world, creates cells, sets up timers, and starts the first wave
func _ready() -> void:
	# set variables 
	GameManager.current_world = self
	GameManager.cursor_plant = $cursor_plant
	
	create_cell()
	cell.visible = false
	wave_progress_bar.max_value = 120
	wave_progress_bar.value = 0
	
	timer_spawn.connect("timeout", next_wave)
	timer_spawn.start()
	
	timer_zombie.connect("timeout", wave_manager)
	
	Global.sun_amount_player = 0
	Global.add_sun(100)
	
	money_label.text = str(int(SaveManager.user_data["money"]))
	Global.update_money_amount.connect(update_money)

## Toggle visibility of the grid cells (called when placing/removing plants)
func show_cell(is_show : bool):
	cell.visible = is_show

## Creates the 17x3 grid of cells that serve as plant placement slots
func create_cell():
	var packet_cell := load("res://scenes/cell.tscn")
	for x in range(0,17):
		for y in range(0,3):
			var new_cell = packet_cell.instantiate()
			cell.add_child(new_cell)
			new_cell.position = Vector2(15, 17.5) + (Vector2(x,y) * Vector2(30,35))
			new_cell.cell_position = Vector2i(x,y)

## Advances to the next wave or ends the wave sequence
## Called by timer_spawn at regular intervals between waves
func next_wave():
	if current_wave < (WaveData.wave_info.size() -1):
		current_wave += 1
		wave_label.text = str(current_wave + 1)
		timer_spawn.start()
		if current_wave == 0:
			timer_zombie.start()
			start_zombie.play()
	else:
		timer_spawn.stop()

## Spawns a single zombie from the current wave's zombie pool
## Uses weighted probability to select which zombie type to spawn
## Called by timer_zombie at randomized intervals
func wave_manager():
	var zombie_pool = WaveData.wave_info[current_wave]["wave-data"]
	var min_time = WaveData.wave_info[current_wave]["min-respawn"]
	var max_time = WaveData.wave_info[current_wave]["max-respawn"]
	
	var spawn_time = randf_range(min_time, max_time)

	if zombie_pool.size() > 0:
		var selected_zombie = get_random_zombie(zombie_pool)
		if selected_zombie != null:
			spawn_zombie(selected_zombie)

	timer_zombie.wait_time = spawn_time
	timer_zombie.start()

## Selects a random zombie type from the pool using cumulative probability
## Returns the selected zombie PackedScene or null if probability selection fails
func get_random_zombie(data):
	var roll = randf()
	var cumulative_probability = 0.0
	
	for entry in data:
		cumulative_probability += entry["probability"]
		if roll <= cumulative_probability:
			return entry["zombie"]
	
	return data[data.size() - 1]["zombie"]

## Instantiates a zombie at a random spawn point in a random lane
## Argument: zombie - The PackedScene of the zombie to spawn
func spawn_zombie(zombie):
	var spawn_points = line.get_children()
	if spawn_points.size() > 0:
		var select_point = spawn_points.pick_random()
		var lane_index = spawn_points.find(select_point)
		var new_zombie = zombie.instantiate()
		
		new_zombie.z_index = lane_index
		new_zombie.global_position = select_point.global_position
		new_zombie.lane = lane_index
		
		get_parent().add_child(new_zombie)

## Updates the wave progress bar to show remaining time until next wave
func _process(_delta):
	wave_progress_bar.value = timer_spawn.time_left

## Called when a zombie reaches the end of the lawn (loses the game)
func _on_area_lose_game_area_entered(_area: Area2D) -> void:
	Global.user_death()

## Toggles the shovel tool for removing plants
func _on_button_shovel_button_down() -> void:
	if !GameManager.is_shovel_show and !GameManager.is_cursor_plant_show:
		shovel_click.play()
		show_cell(true)
		GameManager.is_shovel_show = true
		GameManager.cursor_shovel = cursor_shovel
	elif GameManager.is_shovel_show and !GameManager.is_cursor_plant_show:
		shovel_click.play()
		GameManager.is_shovel_show = false
		GameManager.cursor_shovel.position = Vector2(35, 27)

func update_money(amount : int):
	money_label.text = str(int(amount))
