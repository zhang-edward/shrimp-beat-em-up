class_name PlayerMoveState
extends PlayerState

const MOVE_SPEED = 200.0

@export var jump_state: PlayerJumpState
@export var punch_state: PlayerPunchState

func physics_update(_delta: float) -> void:
	var direction_x = Input.get_axis("move_left", "move_right")
	var direction_y = Input.get_axis("move_up", "move_down")
	player.velocity = Vector2(direction_x * MOVE_SPEED, direction_y * MOVE_SPEED)

	if player.z == 0 and Input.is_action_just_pressed("jump"):
		state_machine.transition_to(jump_state)

func update(_delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		state_machine.transition_to(punch_state)
		return

	# animation
	if player.velocity.length() > 0:
		player.sprite.play("move")
	else:
		player.sprite.play("default")
