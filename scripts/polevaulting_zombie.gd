extends MainZombie

class_name PoleVaultingZombie

const JUMP = 5

const JUMP_SPEED := 40.0

var has_pole := true
var is_jumping := false
var original_speed: float

@onready var detector_shape: CollisionShape2D = $detector/CollisionShape2DDetector


func _ready() -> void:
	super()
	original_speed = zombie_stats["speed"]
	sprite_animation.animation_finished.connect(_on_animation_finished)


func _physics_process(_delta: float) -> void:
	var health_pct = hp / max_hp
	if current_state != previus_state or damage:
		match current_state:
			WALK:
				if has_pole:
					if health_pct > 0.45:
						sprite_animation.play("walk")
					else:
						sprite_animation.play("walk_damage")
					
				else:
					if health_pct > 0.45:
						sprite_animation.play("walk_w_pole")
					else:
						sprite_animation.play("walk_w_pole_damage")
			EAT:
				if health_pct > 0.45:
					sprite_animation.play("eating")
				else:
					sprite_animation.play("eating_damage")
			JUMP:
				if health_pct > 0.45:
					sprite_animation.play("jump")
				else:
					sprite_animation.play("jump_damage")
			WALK_DEATH:
				if !is_eating:
					sprite_animation.play("death_walk")
				else:
					sprite_animation.play("death_eat")
					current_state = EAT_DEATH
			EAT_DEATH:
				sprite_animation.play("death_eat")
			DEATH:
				if !fdeath:
					fdeath = true
					sprite_animation.play("death")
		previus_state = current_state
		damage = false

	if current_state == JUMP:
		velocity.x = JUMP_SPEED * move_direction
	elif current_state == WALK or current_state == WALK_DEATH:
		velocity.x = zombie_stats["speed"] * move_direction
	else:
		velocity.x = 0

	move_and_slide()


func _on_detector_area_entered(area: Area2D) -> void:
	if hp <= 0:
		return
	if current_state == WALK_DEATH:
		current_state = EAT_DEATH
		is_eating = true
		return
	if has_pole and current_state == WALK:
		start_jump()
		return
	current_state = EAT
	plant_to_eat = area.get_parent()
	attack()
	is_eating = true


func _on_detector_area_exited(_area: Area2D) -> void:
	if is_jumping:
		return
	is_eating = false
	if current_state == EAT:
		current_state = WALK
		plant_to_eat = null
		attack_timer.stop()
	elif current_state == EAT_DEATH:
		current_state = WALK_DEATH


func start_jump():
	is_jumping = true
	current_state = JUMP
	detector_shape.disabled = true


func _on_animation_finished():
	if current_state == JUMP:
		finish_jump()


func finish_jump():
	has_pole = false
	zombie_stats["speed"] = original_speed * 0.75
	detector_shape.disabled = false
	is_jumping = false

	var overlapping_areas = $detector.get_overlapping_areas()
	if overlapping_areas.size() > 0:
		var plant = overlapping_areas[0].get_parent()
		if plant:
			current_state = EAT
			plant_to_eat = plant
			attack()
			is_eating = true
	else:
		current_state = WALK
