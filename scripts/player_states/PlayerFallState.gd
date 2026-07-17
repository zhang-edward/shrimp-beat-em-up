class_name PlayerFallState
extends PlayerState

const AIR_MOVE_SPEED = 200.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var move_state: PlayerMoveState
@export var jump_state: PlayerJumpState
@export var jump_slam_state: PlayerJumpSlamState
@export var dash_state: PlayerDashState


func physics_update(delta: float) -> void:
	var direction_x = Input.get_axis("move_left", "move_right")
	var direction_y = Input.get_axis("move_up", "move_down")
	player.velocity = Vector2(direction_x * AIR_MOVE_SPEED, direction_y * AIR_MOVE_SPEED)

	player.z += player.z_velocity * delta
	player.z_velocity += gravity * delta

	if player.z >= 0:
		player.z = 0
		player.z_velocity = 0
		state_machine.transition_to(move_state)
		return

	if Input.is_action_just_pressed("dash"):
		state_machine.transition_to(dash_state, {"prev_state": self})
		return
	if Input.is_action_just_pressed("jump") and player.num_jumps_remaining > 0:
		state_machine.transition_to(jump_state)


func update(_delta: float) -> void:
	if player.z_velocity > 0:
		player.sprite.play("fall")

	if Input.is_action_just_pressed("attack"):
		state_machine.transition_to(jump_slam_state)
