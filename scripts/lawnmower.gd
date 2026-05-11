extends CharacterBody2D

var speed : float = 100.0
var isactive: bool = false

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _physics_process(delta: float) -> void:
	if isactive:
		position.x += speed * delta

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()

func _on_detection_area_entered_detection(area: Area2D) -> void:
	if not isactive:
		isactive = true
		audio_stream_player_2d.play()

func _on_areadamage_area_entered_damage(area: Area2D) -> void:
	var taget_zombie = area.get_parent()
	if taget_zombie is MainZombie:
		
		taget_zombie.death_zombie()
