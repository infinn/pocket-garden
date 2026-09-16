class_name HUD
extends Control

## HUD - Heads-up display showing player sun amount and controls
##
## Displays the current sun balance and provides a cancel button for
## exiting plant placement or shovel mode.
## Updates in real-time as the player gains/spends sun.

@onready var label_sun: Label = %Label

## Initialize HUD and connect to Global sun updates
func _ready() -> void:
	Global.update_sun_amount_player.connect(update_sun_hud)
	GameManager.hud = self
	show_cancel_button(false)
	
	check_seed_in_shop()
	Global.buy_seed_shop.connect(check_seed_in_shop)

## Updates the sun amount display
func update_sun_hud(sun: int):
	label_sun.text = str(sun)

## Handles cancel button press - cancels placement or shovel mode
func _on_button_button_down() -> void:
	GameManager.cancel_place()

## Shows or hides the cancel button
func show_cancel_button(value: bool):
	$Button.visible = value

## Refreshes shop seed availability based on saved unlock data
func check_seed_in_shop():
	$Panel/VBoxContainer2/TwinSunflower.visible = SaveManager.user_data["seed"]["twin_sunflower"]
	$Panel/VBoxContainer2/TwinSunflower.is_can_bought = SaveManager.user_data["seed"]["twin_sunflower"]
	
	$Panel/VBoxContainer2/Repeater.visible = SaveManager.user_data["seed"]["reapeter"]
	$Panel/VBoxContainer2/Repeater.is_can_bought = SaveManager.user_data["seed"]["reapeter"]
	
	$Panel/VBoxContainer2/Tallnut.visible = SaveManager.user_data["seed"]["tall_nut"]
	$Panel/VBoxContainer2/Tallnut.is_can_bought = SaveManager.user_data["seed"]["tall_nut"]
	
	$Panel/VBoxContainer2/SnowPea.visible = SaveManager.user_data["seed"]["snow_pea"]
	$Panel/VBoxContainer2/SnowPea.is_can_bought = SaveManager.user_data["seed"]["snow_pea"]
	
	$Panel/VBoxContainer2/Chomper.visible = SaveManager.user_data["seed"]["chomper"]
	$Panel/VBoxContainer2/Chomper.is_can_bought = SaveManager.user_data["seed"]["chomper"]
