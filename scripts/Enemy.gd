class_name Enemy
extends CharacterBody2D

const AUTO_FACE_PLAYER_RANGE = 200

@export var move_speed := 100.0
@export var playerRef: Player
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var healthbar: ProgressBar = $Healthbar
@onready var state_machine: StateMachine = %StateMachine
@onready var hurt_state: EnemyHurtState = %EnemyHurtState

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var absolute_velocity := Vector2.ZERO

func _ready() -> void:
	pass

func initialize(player: Player) -> void:
	playerRef = player

func _process(delta: float) -> void:
	if velocity.length_squared() > 0:
		sprite.play("move")
	else:
		sprite.play("default")
	
	if velocity.x != 0 and state_machine.state is not EnemyHurtState:
		sprite.flip_h = velocity.x < 0

	if (playerRef.position - position).length() <= AUTO_FACE_PLAYER_RANGE:
		sprite.flip_h = position.x > playerRef.position.x


func _physics_process(delta: float) -> void:
	velocity = MovementUtils.scale_velocity(absolute_velocity)
	move_and_slide()

func damage(amount: int, source: Node2D):
	healthbar.value -= amount
	if healthbar.value == 0:
		queue_free()

	var dir = Vector2(position.x - source.position.x, 0)
	state_machine.transition_to(hurt_state, {"dir": dir})
