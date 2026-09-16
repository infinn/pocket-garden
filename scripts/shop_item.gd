extends Control

@onready var price: Label = $Price
@onready var sprite: TextureRect = $Sprite
@onready var panel: Panel = $"."
@onready var bg: TextureRect = $bg

@export var plant_name : String = "twin_sunflower"
@export var cost : int = 100
@export var texture : Texture2D

func _ready() -> void:
	sprite.texture = texture
	price.text = str(cost)
	
	if SaveManager.user_data["seed"][plant_name]:
		panel.visible = false
	
	check_is_avaliable(SaveManager.user_data["money"])
	Global.update_money_amount.connect(check_is_avaliable)


func _on_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left-click") and Global.money >= cost:
		Global.buy_seed_in_shop(cost, plant_name)
		panel.visible = false

func check_is_avaliable(player_money : int):
	if player_money < cost:
		sprite.self_modulate = Color(0.487, 0.487, 0.487, 1.0)
		bg.self_modulate = Color(0.487, 0.487, 0.487, 1.0)
	else:
		sprite.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		bg.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
