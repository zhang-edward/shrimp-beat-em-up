class_name Enemy
extends CharacterBody2D

const AUTO_FACE_PLAYER_RANGE = 200

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

func _process(delta: float) -> void:
	if velocity.length_squared() > 0:
		sprite.play("move")
	else:
		sprite.play("default")
	
	if velocity.x != 0 and state_machine.state is not EnemyHurtState:
		sprite.flip_h = velocity.x < 0

	if (player_ref.position - position).length() <= AUTO_FACE_PLAYER_RANGE:
		sprite.flip_h = position.x > player_ref.position.x


func _physics_process(delta: float) -> void:
	velocity = MovementUtils.scale_velocity(absolute_velocity)
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
