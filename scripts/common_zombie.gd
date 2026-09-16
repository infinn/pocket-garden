
## MainZombie - Represents a zombie enemy in the game
##
## Handles zombie states, movement, attacking plants, taking damage, and death logic.
## Loads stats from DataManager and manages animations, sound, and rewards.
## Used for all standard zombie behaviors and interactions on the game grid.

# MainZombie: Handles zombie behavior, states, and interactions in the game
class_name MainZombie
extends CharacterBody2D


# Zombie states
enum{WALK, EAT, WALK_DEATH, EAT_DEATH, DEATH}

# Debuff types applied by bullets
enum DebuffType { COLD }

# Duration of a cold debuff in seconds (resets on every hit)
const COLD_DURATION : float = 10.0
# Movement slow multiplier applied while cold (20% slower)
const COLD_SLOW_FACTOR : float = 0.5


# Movement and state variables
var move_direction := -1
var current_state: int = WALK
var previus_state


# Zombie stats
@export var zombie_name = "Flag zombie"
@export var attack_damage : int = 100
@export var helmet : bool = false
@export var lane : int = 0


var zombie_stats: Dictionary = {}
var hp : float = 100.0
var armor : float = 0
var max_hp : float = 100.0
var walk_death : float = 45.0 # HP left for death animation


# State flags
var plant_to_eat = MainPlant
var damage : bool = false
var fdeath : bool = false # Ensures death is triggered once
var is_eating : bool = false
var has_head : bool = true
var has_money : bool = false


# Node references
@onready var sprite_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $Attack_timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var death_timer: Timer = $Death_timer
@onready var collision_shape_2d_detector: CollisionShape2D = $detector/CollisionShape2DDetector
@onready var animated_sprite_helmet: AnimatedSprite2D = $AnimatedSpriteHelmet
@onready var hitbox: Area2D = $hitbox
@onready var head_particle: CPUParticles2D = $HeadParticle
@onready var eating_sfx: AudioStreamPlayer2D = $EatingSFX
@onready var money_particle: CPUParticles2D = $MoneyParticle
@onready var money_sfx: AudioStreamPlayer2D = $MoneySFX


# Debuff state
var cold_active : bool = false
var cold_timer : Timer


# Called when the node is added to the scene
func _ready() -> void:
	if DataManager.zombies_data.has(zombie_name): 
		zombie_stats = DataManager.zombies_data[zombie_name]
		# Set up timers and stats from data
		attack_timer.wait_time = zombie_stats["attack-speed"]
		attack_timer.connect("timeout", attack)
		death_timer.connect("timeout", death_zombie)
		hp = zombie_stats["hp"]
		armor = zombie_stats["armor"]
		max_hp = zombie_stats["hp"]
		walk_death = zombie_stats["death-hp"]
		if !helmet:
			animated_sprite_helmet.visible = false
		# Calculate money drop probability
		var probability = clamp((hp + armor) / 10000.0, 0.0, 0.95)
		has_money = randf() < probability
		# Set up cold debuff timer
		cold_timer = Timer.new()
		cold_timer.wait_time = COLD_DURATION
		cold_timer.one_shot = true
		cold_timer.timeout.connect(_on_cold_timeout)
		add_child(cold_timer)
	else:
		push_error("No data for zombie: " + zombie_name)
		queue_free()


# Handles zombie movement and animation state per frame
func _physics_process(_delta: float) -> void:
	var health_pct = hp / max_hp
	if current_state != previus_state or damage:
		match current_state:
			WALK:
				if health_pct > 0.45:
					sprite_animation.play("walk")
				elif health_pct > 0.0:
					sprite_animation.play("walk_damage")
			EAT:
				if health_pct > 0.45:
					sprite_animation.play("eating")
				elif health_pct > 0.0:
					sprite_animation.play("eating_damage")
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
	# Move zombie if walking
	if current_state == WALK or current_state == WALK_DEATH and !is_eating:
		var move_speed = zombie_stats["speed"]
		if cold_active:
			move_speed *= COLD_SLOW_FACTOR
		velocity.x = move_speed * move_direction
	else:
		velocity.x = 0
	move_and_slide()



# Called when zombie detects a plant to eat
func _on_detector_area_entered(area: Area2D) -> void:
	if current_state != WALK_DEATH or current_state != DEATH and hp > 0:
		current_state = EAT
		plant_to_eat = area.get_parent()
		attack()
		is_eating = true
	elif current_state == WALK_DEATH:
		current_state = EAT_DEATH
		is_eating = true



# Called when zombie stops colliding with a plant
func _on_detector_area_exited(_area: Area2D) -> void:
	is_eating = false
	if current_state == EAT:
		current_state = WALK
		plant_to_eat = null
		attack_timer.stop()
	elif current_state == EAT_DEATH:
		current_state = WALK_DEATH


# Inflicts damage to the plant being eaten
func attack():
	if plant_to_eat != null and hp >0:
		plant_to_eat.take_damage(attack_damage)
		attack_timer.start()
		eating_sfx.play()


# Handles zombie taking damage, including armor and death logic
func take_damage(amount: float):
	if helmet and armor > 0:
		armor -= amount
		animation_player.play("helmet_damage")
		var armor_pct = armor / zombie_stats["armor"]
		if armor_pct > 0.60:
			animated_sprite_helmet.play("full")
		elif  armor > 0.40:
			animated_sprite_helmet.play("damage")
		elif armor > 0:
			animated_sprite_helmet.play("full-damage")
		else:
			animated_sprite_helmet.visible = false
			helmet = false
	else:
		hp -= amount
		animation_player.play("take_damage")
		damage = true
		# Trigger death state if HP is depleted
		if hp <= 0 and (current_state == WALK or current_state == EAT):
			current_state = WALK_DEATH
			death_timer.start()
			if(has_head):
				head_particle.emitting = true
				has_head = false
		elif current_state == WALK_DEATH or current_state == EAT_DEATH:
			walk_death -= amount
			if walk_death <= 0:
				hitbox.monitoring = false
				death_zombie()


# Applies a debuff to the zombie, refreshing its duration each time it is hit
func apply_debuff(type: String) -> void:
	match type:
		"cold":
			cold_active = true
			animation_player.play("take_cold")
			cold_timer.start() # Restarts the timer, keeping the debuff at 2s


# Clears the cold debuff when its timer expires
func _on_cold_timeout() -> void:
	cold_active = false

# Handles zombie death, cleanup, and rewards
func death_zombie():
	current_state = DEATH
	hitbox.monitoring = false
	if has_money:
		drop_money()
	if helmet and armor > 0:
		animated_sprite_helmet.visible = false
	await get_tree().create_timer(2.0).timeout
	Global.add_sun(5)
	Global.add_zombie_kill()
	queue_free()

# Drops money when zombie dies (if eligible)
func drop_money():
	Global.add_money(5)
	money_sfx.play()
	money_particle.emitting = true
# olamiamor teamo mucho mucho :3 <3
