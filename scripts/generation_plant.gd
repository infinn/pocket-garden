class_name GenerationPlant
extends MainPlant

@onready var timer : Timer = $Timer
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var sun_particle : CPUParticles2D = $Sun_Particle
@onready var generation_sfx : AudioStreamPlayer2D = $GenerationSFX

@export var plant_name : String = "Sunflower"
@export var sun_generation : int = 25

func _ready() -> void:
	super._ready()
	super.setup(plant_name)
	
	setup_generation_logic()

func setup_generation_logic():
	
	if timer:
		timer.wait_time = plant_stats["preparation-time"]
		if not timer.timeout.is_connected(_on_timer_timeout):
			timer.timeout.connect(_on_timer_timeout)
		timer.start()

func _on_timer_timeout():
	generate_sun()

func generate_sun():
	Global.add_sun(sun_generation)
	sun_particle.emitting = true
	generation_sfx.play()
