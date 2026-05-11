extends Node2D

var health: float
var plant_stats: Dictionary = {}
var is_active: bool = false
var is_explode: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var damage_area: Area2D = $DamageArea
@onready var bomb_explotion: CPUParticles2D = $BombExplotion
@export var cell_plant: Vector2i
@onready var explotion_sfx: AudioStreamPlayer2D = $ExplotionSFX

signal reduce_healt(healt_left)

func _ready() -> void:
	timer.start()
	timer.connect("timeout", explode)

func explode():
	bomb_explotion.emitting = true
	animated_sprite_2d.hide()
	
	var targets = damage_area.get_overlapping_areas()
	
	for target in targets:
		if target.has_method("death_zombie"):
			target.death_zombie()
		elif target.get_parent().has_method("death_zombie"):
			target.get_parent().death_zombie()
	
	GameManager.delete_plant(cell_plant, "cherry-bomb") 
	
	explotion_sfx.play()
	
	damage_area.monitoring = false
	
	await get_tree().create_timer(2).timeout
	queue_free()
