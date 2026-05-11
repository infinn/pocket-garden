extends Node

## First global script to run
##
## it controls the player's sun count and emits signals for the other scripts.

signal update_sun_amount_player(amount)
signal update_money_amount(amount)
signal user_is_dead()
signal buy_seed_shop()

var sun_amount_player : int = 100
var zombies_killed : int = 0
var money : int = 0

const width_viewport = 642
const height_viewport = 191

func _ready() -> void:
	get_viewport().transparent_bg = true
	
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)

func add_sun(amount : int):
	sun_amount_player += amount
	update_sun_amount_player.emit(sun_amount_player)

func subtract_sun(amount : int):
	sun_amount_player -= amount
	update_sun_amount_player.emit(sun_amount_player)

func user_death():
	user_is_dead.emit()

func add_zombie_kill():
	zombies_killed += 1

func add_money(amoun: int):
	money += amoun
	update_money_amount.emit(money)
	SaveManager.user_data["money"] = money
	SaveManager.save_data()

func subtract_money(amoun: int):
	money -= amoun
	update_money_amount.emit(money)
	SaveManager.user_data["money"] = money
	SaveManager.save_data()

func change_viewport_scale(perc : float):
	var new_width = width_viewport * perc
	var new_height = height_viewport * perc
	
	var win = get_window()
	win.size = Vector2i(new_width, new_height)

func buy_seed_in_shop(amount : int, plant_name : String):
	subtract_money(amount)
	SaveManager.user_data["seed"][plant_name] = true
	SaveManager.save_data()
	buy_seed_shop.emit()
