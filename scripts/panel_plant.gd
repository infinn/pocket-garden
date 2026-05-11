extends Panel
class_name PanelPlant

## PanelPlant - Represents a plant card in the plant selection panel
##
## Each plant card shows the plant's texture, sun cost, and recharge status.
## When clicked, it initiates plant placement mode via GameManager.
##
## Features:
##   - Dynamic sun cost based on the number of plants already placed (tax system)
##   - Seed recharge timer that prevents spam clicking
##   - Visual feedback (greyscale when not affordable)
##   - Tracks plant statistics from DataManager
##
## The card becomes unavailable for the seed_recharge duration after placing a plant,
## then automatically becomes available again. Sun costs increase by 20% for each
## plant beyond the 2nd one, and decrease by 10% when a plant is removed.

@export var texture : Texture2D
@export var seed_recharge : float = 2.0
@export var sun_cost : int = 25
@export var plant_name = "sunflower"
@export var plant_setup : PackedScene
@export var is_can_bought : bool = true

## Can this plant currently be placed?
var is_avaliable : bool = true
## Number of this plant currently alive on the board
var plants_numbers : int = 0
## Original sun cost (before tax system modifications)
var origin_cost : int = 0

@onready var timer: Timer = $Timer
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label
@onready var click_sfx: AudioStreamPlayer2D = $ClickSFX
@onready var plant_sfx: AudioStreamPlayer2D = $PlantSFX
@onready var cant_buy_sfx: AudioStreamPlayer2D = $CantBuySFX
@onready var texture_rect: TextureRect = $TextureRect

## Loads plant statistics from DataManager and initializes the UI
func _ready() -> void:
	search_plant(plant_name)
	Global.update_sun_amount_player.connect(check_is_avaliable)
	GameManager.plant_placed.connect(start_seed_recharge)
	GameManager.plant_delete.connect(check_dead_plant)

## Loads plant data from DataManager and initializes the panel UI with correct stats
func search_plant(plant_name : String):
	if DataManager.plant_data.has(plant_name): 
		var plant_stats = DataManager.plant_data[plant_name]
		seed_recharge = plant_stats["seed-recharge"]
		sun_cost = plant_stats["sun-cost"]
		origin_cost = sun_cost
		
		texture_rect.texture = texture
		label.text = str(sun_cost)

		progress_bar.max_value = seed_recharge
		progress_bar.value = 0
		
		timer.wait_time = seed_recharge
		timer.connect("timeout", finish_seed_recharge)

## Handles card click - initiates plant placement if player has enough sun
func _on_gui_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left-click") and is_avaliable and !GameManager.is_shovel_show and is_can_bought:
		GameManager.select_plant(self)
		if Global.sun_amount_player >= sun_cost:
			click_sfx.play()
		else:
			cant_buy_sfx.play()

## Starts the seed recharge cooldown when this plant is placed
## Also applies tax if more than 2 of this plant are placed
func start_seed_recharge(name : String):
	if plant_name == name:
		progress_bar.value = seed_recharge
		is_avaliable = false
		plants_numbers += 1
		set_tax()
		plant_sfx.play()
		timer.start()

## Updates progress bar in real time during recharge
func _process(_delta):
	progress_bar.value = timer.time_left

## Called when seed recharge timer completes - makes the card available again
func finish_seed_recharge():
	is_avaliable = true

## Updates card visual state based on whether player can afford the plant
func check_is_avaliable(player_sun : int):
	if player_sun < sun_cost:
		texture_rect.self_modulate = Color(0.487, 0.487, 0.487, 1.0)
	else:
		texture_rect.self_modulate = Color(1.0, 1.0, 1.0, 1.0)

## Applies the tax system: each plant beyond the 2nd increases cost by 20%
func set_tax():
	if plants_numbers > 2:
		sun_cost = int(round(sun_cost * 1.2))
		label.text = str(sun_cost)

## Handles plant removal - reduces plant count and decreases cost if applicable
func check_dead_plant(name : String):
	if plant_name == name:
		plants_numbers -= 1
		sun_cost = int(round(sun_cost / 1.10))
		if plants_numbers < 3:
			sun_cost = origin_cost
			label.text = str(sun_cost)
		elif sun_cost > origin_cost:
			label.text = str(sun_cost)
