class_name Enemy
extends CharacterBody2D

const MAX_AGGRO_ENEMIES := 2

@export var move_speed := 100.0
@export var player_ref: Player

@onready var game: Game = get_node("/root/Game") as Game
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var healthbar: ProgressBar = $Healthbar
@onready var state_machine: StateMachine = %StateMachine
@onready var hurt_state: EnemyHurtState = %EnemyHurtState

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var absolute_velocity := Vector2.ZERO
var enemy_config: EnemyConfig = preload("res://resources/enemies/Fish.tres")

func _ready() -> void:
	sprite.sprite_frames = enemy_config.sprite_frames
	healthbar.max_value = enemy_config.max_health
	healthbar.value = healthbar.max_value

func initialize(player: Player, config: EnemyConfig) -> void:
	player_ref = player
	enemy_config = config

# func _process(delta: float) -> void:
func _physics_process(delta: float) -> void:
	velocity = IsometryUtils.scale_velocity(absolute_velocity)
	move_and_slide()

func damage(amount: int, source: Node2D):
	healthbar.value -= amount
	if healthbar.value == 0:
		game.incr_enemy_defeated_count()
		queue_free()
	var dir = Vector2(position.x - source.position.x, 0)
	state_machine.transition_to(hurt_state, {"dir": dir})

func get_sprite_size():
	return sprite.sprite_frames.get_frame_texture("default", 0).get_size() * sprite.scale

func is_aggroing() -> bool:
	return state_machine.state is EnemyApproachState or state_machine.state is EnemyAttackState

# Excludes self, so the answer holds whether claiming a slot or keeping one
func can_take_aggro_slot() -> bool:
	var others_aggroing := 0
	for other in get_parent().get_children():
		if other != self and is_instance_valid(other) and other is Enemy and other.is_aggroing():
			others_aggroing += 1
	return others_aggroing < MAX_AGGRO_ENEMIES
