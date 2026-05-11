class_name MainPlant
extends Node2D

var health: float
var plant_stats: Dictionary = {}
@export var cell_plant: Vector2i

signal reduce_healt(healt_left)

func _ready() -> void:
	pass

func setup(plant_name: String):
	# search for plant in data
	if DataManager.plant_data.has(plant_name): 
		plant_stats = DataManager.plant_data[plant_name]
		health = plant_stats["hp"]
	else:
		push_error("No se encontraron datos para la planta: " + plant_name)

func take_damage(amount: float):
	health -= amount
	if health <= 0:
		queue_free()
		GameManager.delete_plant(cell_plant, plant_stats["name"])
	else:
		reduce_healt.emit(health)
