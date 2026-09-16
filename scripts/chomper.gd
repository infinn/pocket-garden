extends Node2D

## Chomper - Detects zombies in front and instantly kills them
##
## Has 3 states:
##   IDLE     - Plays idle animation, detection Area2D monitors for zombies
##   EATING   - Zombie detected, plays atack animation (bite), starts cooldown
##   COOLDOWN - Digesting, plays eating animation, detection disabled
##              When timer expires, returns to IDLE

enum State { IDLE, EATING, COOLDOWN }

var health: float
var plant_stats: Dictionary = {}
var current_state: State = State.IDLE

@export var cell_plant: Vector2i
@export var plant_name: String = "Chomper"

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var hitbox: Area2D = $hitbox
@onready var zombie_detector: Area2D = $ZombieDetector

signal reduce_healt(healt_left)

func _ready() -> void:
	setup(plant_name)

func setup(plant_name: String):
	if DataManager.plant_data.has(plant_name):
		plant_stats = DataManager.plant_data[plant_name]
		health = plant_stats["hp"]

		timer.wait_time = plant_stats["preparation-time"]

		animated_sprite_2d.play("idle")
	else:
		push_error("No se encontraron datos para la planta: " + plant_name)

func eat_zombie(area: Area2D) -> void:
	if current_state != State.IDLE:
		return

	var zombie = area.get_parent()
	if zombie is MainZombie and zombie.hp > 0:
		current_state = State.EATING
		zombie_detector.set_deferred("monitoring", false)
		zombie.death_zombie()
		animated_sprite_2d.play("atack")

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "atack":
		current_state = State.COOLDOWN
		animated_sprite_2d.play("eating")
		timer.start()

func _on_timer_timeout() -> void:
	current_state = State.IDLE
	animated_sprite_2d.play("idle")
	zombie_detector.set_deferred("monitoring", true)

func take_damage(amount: float):
	health -= amount
	if health <= 0:
		queue_free()
		GameManager.delete_plant(cell_plant, plant_stats["name"])
	else:
		reduce_healt.emit(health)

func _on_zombie_detector_area_entered(area: Area2D) -> void:
	eat_zombie(area)
