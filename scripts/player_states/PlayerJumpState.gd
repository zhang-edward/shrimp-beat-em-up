class_name PlayerJumpState
extends PlayerState

const AIR_MOVE_SPEED = 200.0
const JUMP_VELOCITY = 500
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var jump_slam_state: PlayerJumpSlamState
@export var uppercut_state: PlayerUppercutState
@export var dash_state: PlayerDashState
@export var fall_state: PlayerFallState

func enter(_msg := {}) -> void:
	player.play_jump_sfx()
	player.num_jumps_remaining -= 1
	player.z_velocity = - JUMP_VELOCITY
	player.sprite.play("jump")


func physics_update(delta: float) -> void:
	var direction_x = Input.get_axis("move_left", "move_right")
	var direction_y = Input.get_axis("move_up", "move_down")
	player.velocity = Vector2(direction_x * AIR_MOVE_SPEED, direction_y * AIR_MOVE_SPEED)

	player.z += player.z_velocity * delta
	player.z_velocity += gravity * delta

	if player.z_velocity >= 0:
		state_machine.transition_to(fall_state)
		return

	if Input.is_action_just_pressed("dash"):
		state_machine.transition_to(dash_state, {"prev_state": fall_state})
		return
	if Input.is_action_just_pressed("jump") and player.num_jumps_remaining > 0:
		state_machine.transition_to(self)


func update(_delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		if player.z_velocity > -100:
			state_machine.transition_to(jump_slam_state)
		elif not player.uppercut_used:
			state_machine.transition_to(uppercut_state)
