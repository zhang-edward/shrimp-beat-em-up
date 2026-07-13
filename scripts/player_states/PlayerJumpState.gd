class_name PlayerJumpState
extends PlayerState

const AIR_MOVE_SPEED = 200.0
const JUMP_VELOCITY = 500
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var move_state: PlayerMoveState
@export var jump_slam_state: PlayerJumpSlamState
@export var uppercut_state: PlayerUppercutState

var from_uppercut: bool

func enter(msg := {}) -> void:
	player.sprite.play("jump")
	from_uppercut = msg.has("from_uppercut") and msg["from_uppercut"] == true
	if !from_uppercut:
		player.z_velocity = - JUMP_VELOCITY

func physics_update(delta: float) -> void:
	var direction_x = Input.get_axis("move_left", "move_right")
	var direction_y = Input.get_axis("move_up", "move_down")
	player.velocity = Vector2(direction_x * AIR_MOVE_SPEED, direction_y * AIR_MOVE_SPEED)

	player.z += player.z_velocity * delta

	if player.z < 0:
		player.z_velocity += gravity * delta
	else:
		player.z = 0
		player.z_velocity = 0
		state_machine.transition_to(move_state)


func update(_delta: float) -> void:
	if player.z_velocity > 0:
		player.sprite.play("fall")

	if Input.is_action_just_pressed("attack"):
		if player.z_velocity > -100:
			state_machine.transition_to(jump_slam_state)
			return
		elif player.z_velocity < 0 and not from_uppercut:
			state_machine.transition_to(uppercut_state)
