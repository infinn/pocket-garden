class_name AttackPlant
extends MainPlant

@onready var timer : Timer = $Timer
@onready var sprite = $AnimatedSprite2D
@onready var ray_cast_2d : RayCast2D = $RayCast2D
@onready var shoot_sfx : AudioStreamPlayer2D = $ShootSFX

@export var marker_2d : Marker2D
@export var plant_name : String = "Peashooter"
@export var bullet_instantiate : PackedScene
@export var bullet_number : int = 1

var is_zombie_in_range : bool = true

func _ready() -> void:
	super._ready()
	super.setup(plant_name)
	
	setup_raycast()
	
	timer.wait_time = plant_stats["preparation-time"]
	timer.timeout.connect(shoot)
	
	timer.start()
	play_animation("idle")

func play_animation(name):
	if sprite and sprite.sprite_frames.has_animation(name):
		sprite.play(name)

func shoot():
	if ray_cast_2d.is_colliding():
		var target = ray_cast_2d.get_collider()
		if target.get_parent() is MainZombie:
			play_animation("shoot")

func spawn_bullet():
	var bullet = bullet_instantiate.instantiate()
	bullet.lane = cell_plant.y
	
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = marker_2d.global_position
	
	if shoot_sfx.playing:
		shoot_sfx.stop()
		
	shoot_sfx.play()

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "shoot":
		for i in range(bullet_number):
			spawn_bullet()
			await get_tree().create_timer(0.1).timeout
		
		play_animation("idle")

func setup_raycast():
	ray_cast_2d.enabled = true
	
	var screen_width = get_viewport_rect().size.x
	var plant_x = global_position.x
	var distance_to_end = screen_width - plant_x
	
	ray_cast_2d.target_position = Vector2(distance_to_end, 0)
