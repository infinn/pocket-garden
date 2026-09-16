extends Node2D

var health: float
var plant_stats: Dictionary = {}
var is_active: bool = false
var is_explode: bool = false

@export var cell_plant : Vector2i
@export var plant_name : String = "Potato Mine"
@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var explotion : Sprite2D = $Explotion
@onready var text_emition : CPUParticles2D = $TextEmition
@onready var timer : Timer = $Timer
@onready var hitbox : Area2D = $hitbox
@onready var damage_area : Area2D = $DamageArea
@onready var explotion_sfx : AudioStreamPlayer2D = $ExplotionSFX
@onready var preparation_sfx : AudioStreamPlayer2D = $PreparationSFX

signal reduce_healt(healt_left)

func _ready() -> void:
	setup("Potato Mine")
	

func explode():
	explotion.show()
	text_emition.emitting = true
	animated_sprite_2d.hide()
	is_explode = true
	var targets = damage_area.get_overlapping_areas()
	
	for target in targets:
		if target.has_method("death_zombie"):
			target.death_zombie()
		elif target.get_parent().has_method("death_zombie"):
			target.get_parent().death_zombie()
	GameManager.delete_plant(cell_plant, plant_stats["name"]) 
	
	explotion_sfx.play()
	
	damage_area.monitoring = false
	await get_tree().create_timer(3.5).timeout
	queue_free()

func setup(p_name: String):
	# search for plant in data
	if DataManager.plant_data.has(p_name): 
		plant_stats = DataManager.plant_data[p_name]
		
		health = plant_stats["hp"]
		
		timer.wait_time = plant_stats["preparation-time"]
		timer.timeout.connect(_on_timer_timeout)
		timer.start()
	else:
		push_error("No se encontraron datos para la planta: " + p_name)

func _on_timer_timeout():
	animated_sprite_2d.play("idle")
	is_active = true
	hitbox.monitoring = false
	preparation_sfx.play()
	timer.stop()

func take_damage(amount: float):
	if !is_active:
		health -= amount
		if health <= 0:
			queue_free()
			GameManager.delete_plant(cell_plant, plant_stats["name"])
		else:
			reduce_healt.emit(health)


func _on_detection_area_area_entered(_area: Area2D) -> void:
	if is_active and !is_explode:
		explode()
