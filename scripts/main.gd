extends Node2D

## Main - Main scene controller for the game
##
## Handles:
##   - Game state (paused, playing, game over)
##   - UI overlays (pause menu, start menu, death screen)
##   - Audio management (SFX muting, background music)
##   - Window setup (fullscreen, positioning)
##   - Scene reloading and quitting
##
## Signal flow:
##   - Global.user_is_dead triggers death screen
##   - Buttons emit signals to control game flow
##   - Audio buses are controlled for mute functionality

@onready var buton_pause: Button = $ButonPause
@onready var pause: Control = $Pause
@onready var start_menu: Control = $StartMenu
@onready var pause_sfx: AudioStreamPlayer2D = $Pause/PauseSFX
@onready var button_click_sfx: AudioStreamPlayer2D = $ButtonClickSFX
@onready var death_view: Control = $DeathView
@onready var death_sfx: AudioStreamPlayer2D = $DeathView/DeathSFX
@onready var leave: Control = $StartMenu/Leave
@onready var info_death_label: Label = $DeathView/InfoDeathLabel
@onready var money_label: Label = $ShopMenu/Panel/MoneyLabel
@onready var shop_menu: Control = $ShopMenu

var is_paused : bool = true
var is_playing : bool = true

## Initialize game state, connect signals
func _ready() -> void:
	var root = get_tree().get_root()
	
	get_viewport().transparent_bg = true
	
	get_tree().paused = true
	Global.user_is_dead.connect(user_dead)
	Global.update_money_amount.connect(update_money_label)
	
	$Pause/SFXCheckBox.button_pressed = SaveManager.user_data["config"]["music"]
	$Pause/OptionButton.selected = int(SaveManager.user_data["config"]["direction"])
	$Pause/OptionButton2.selected = int(SaveManager.user_data["config"]["scale"])
	
	match int(SaveManager.user_data["config"]["scale"]):
		0:
			Global.change_viewport_scale(0.8)
		1:
			Global.change_viewport_scale(1.0)
		2:
			Global.change_viewport_scale(1.25)
	
	setup_windows()
	
	AudioServer.set_bus_mute(0, !SaveManager.user_data["config"]["music"])

func setup_windows():
	await get_tree().process_frame
	
	var usable_rect = DisplayServer.screen_get_usable_rect()
	var window_size = DisplayServer.window_get_size()
	
	if SaveManager.user_data["config"]["direction"] == 0:
		var target_pos = Vector2i(
			usable_rect.position.x, 
			usable_rect.position.y + (usable_rect.size.y - window_size.y)
			)
		DisplayServer.window_set_position(target_pos)
	
	if SaveManager.user_data["config"]["direction"] == 1:
		var target_pos = Vector2i(
			usable_rect.position.x + (usable_rect.size.x - window_size.x), 
			usable_rect.position.y + (usable_rect.size.y - window_size.y)
		)
		DisplayServer.window_set_position(target_pos)

## Shows the pause menu and pauses the game
func _on_buton_pause_button_down() -> void:
	if !is_paused:
		is_paused = true
		pause.visible = true
		get_tree().paused = true
		pause_sfx.play()

## Toggles SFX on/off by muting the master audio bus
func _on_sfx_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioServer.set_bus_mute(0, false)
		SaveManager.user_data["config"]["music"] = false
		SaveManager.save_data()
		button_click_sfx.play()
	else:
		AudioServer.set_bus_mute(0, true)
		SaveManager.user_data["config"]["music"] = true
		SaveManager.save_data()

## Resumes the game from pause menu
func _on_back_to_game_button_down() -> void:
	button_click_sfx.play()
	is_paused = false
	pause.visible = false
	get_tree().paused = false

## Returns to main menu from pause menu or death screen
func _on_main_menu_button_down() -> void:
	button_click_sfx.play()
	GameManager.reset_scene()
	get_tree().reload_current_scene()

## Handles player death - shows death screen
func user_dead():
	death_sfx.play()
	info_death_label.text = "You have killed " + str(Global.zombies_killed) + " zombies"
	if SaveManager.user_data["highscore"] < Global.zombies_killed:
		SaveManager.user_data["highscore"] = Global.zombies_killed
	
	SaveManager.user_data["score_sum"] += Global.zombies_killed
	Global.add_money(50)
	
	get_tree().paused = true
	death_view.visible = true

## Starts the game from the start menu
func _on_start_button_button_down() -> void:
	button_click_sfx.play()
	get_tree().paused = false
	is_paused = false
	start_menu.visible = false

## Restarts the game from death screen
func _on_ok_button_die_button_down() -> void:
	button_click_sfx.play()
	get_tree().reload_current_scene()

# MARK: - Leave section
## Shows the quit confirmation dialog
func _on_back_button_leave_button_down() -> void:
	button_click_sfx.play()
	leave.visible = true

## Confirms and quits the game
func _on_leave_button_button_down() -> void:
	get_tree().quit()

## Cancels the quit dialog
func _on_cancel_button_leave_button_down() -> void:
	button_click_sfx.play()
	leave.visible = false


func _on_option_button_item_selected(index: int) -> void:
	if index == 0:
		await get_tree().process_frame
	
		var usable_rect = DisplayServer.screen_get_usable_rect()
		var window_size = DisplayServer.window_get_size()
		
		var target_pos = Vector2i(
			usable_rect.position.x, 
			usable_rect.position.y + (usable_rect.size.y - window_size.y)
			)
			
		DisplayServer.window_set_position(target_pos)
		SaveManager.user_data["config"]["direction"] = index
		SaveManager.save_data()
		button_click_sfx.play()

	elif index == 1:
		await get_tree().process_frame
	
		var usable_rect = DisplayServer.screen_get_usable_rect()
		var window_size = DisplayServer.window_get_size()
		
		var target_pos = Vector2i(
			usable_rect.position.x + (usable_rect.size.x - window_size.x), 
			usable_rect.position.y + (usable_rect.size.y - window_size.y)
		)
			
		DisplayServer.window_set_position(target_pos)
		SaveManager.user_data["config"]["direction"] = index
		SaveManager.save_data()
		button_click_sfx.play()


## change viewport scale
func _on_option_button_2_item_selected(index: int) -> void:
	button_click_sfx.play()
	match index:
		0:
			Global.change_viewport_scale(0.8)
		1:
			Global.change_viewport_scale(1.0)
		2:
			Global.change_viewport_scale(1.25)
	SaveManager.user_data["config"]["scale"] = index
	SaveManager.save_data()
	setup_windows()

## Github button
func _on_github_button_pressed() -> void:
	button_click_sfx.play()
	OS.shell_open("https://github.com/infinn/pocket-garden")

## shop button
func _on_shop_button_pressed() -> void:
	money_label.text = str(Global.money)
	shop_menu.visible = true

func _on_back_button_shop_pressed() -> void:
	shop_menu.visible = false

#shop money
func update_money_label(amount : int):
	money_label.text = str(amount)
