class_name PlayerJumpState
extends PlayerState

const AIR_MOVE_SPEED = 200.0
const JUMP_VELOCITY = 500
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var move_state: PlayerMoveState

func enter(_msg := {}) -> void:
	player.sprite.play("jump")
	player.z_velocity = - JUMP_VELOCITY

func physics_update(delta: float) -> void:
	var direction_x = Input.get_axis("move_left", "move_right")
	var direction_y = Input.get_axis("move_up", "move_down")
	player.velocity = Vector2(direction_x * AIR_MOVE_SPEED, direction_y * AIR_MOVE_SPEED)

	player.z += player.z_velocity * delta

	if player.z < 0:
		player.z_velocity += gravity * delta
	else:
		state_machine.transition_to(move_state)


func update(_delta: float) -> void:
	if player.z_velocity > 0:
		player.sprite.play("fall")


func exit() -> void:
	player.z = 0
	player.z_velocity = 0
