class_name bullet
extends Area2D

enum BulletType { NORMAL, FIRE, COLD }

var speed : float = 100.0
var lane: int

@export var bullet_type: int = BulletType.NORMAL

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var splash_sfx: AudioStreamPlayer2D = $SplashSFX

func _physics_process(delta: float) -> void:
	position.x += speed * delta

# delete when is not visible in screen
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	var taget_zombie = area.get_parent()
	if taget_zombie is MainZombie and taget_zombie.lane == lane:
		sprite.play("splash")
		
		taget_zombie.take_damage(10)
		if bullet_type == BulletType.COLD:
			taget_zombie.apply_debuff("cold")
		speed = 0
		splash_sfx.play()
		await get_tree().create_timer(0.8).timeout
		queue_free()
