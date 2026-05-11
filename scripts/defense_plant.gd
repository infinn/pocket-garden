class_name DefensePlant
extends MainPlant

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var plant_name: String = "Wall-nut"

func _ready() -> void:
	super._ready()
	super.setup(plant_name)
	
	reduce_healt.connect(check_healt)

func check_healt(current_health: float):
	var max_health = plant_stats["hp"]
	var health_pct = current_health / max_health
	if health_pct > 0.75:
		sprite.play("idle")
	elif health_pct > 0.40:
		sprite.play("damaged")
	elif health_pct > 0:
		sprite.play("critical")
