class_name EnemyWanderState
extends EnemyState

const WANDER_TIME_SECONDS_MAX := 3.0
const WANDER_TIME_SECONDS_MIN := 1.0
const PAUSE_TIME_SECONDS_MAX := 4.0
const PAUSE_TIME_SECONDS_MIN := 1.0
const STATE_DURATION_SECONDS := 10.0

@export var nextState: State

var state_timer := 0.0 # Timer to track how long the enemy has been in the current state
var timer := 0.0
var wandering := false
var random_direction := Vector2.ZERO

func enter(_msg := {}) -> void:
	state_timer = STATE_DURATION_SECONDS
	timer = randf_range(PAUSE_TIME_SECONDS_MIN, PAUSE_TIME_SECONDS_MAX)
	wandering = false
	random_direction = Vector2.ZERO

func update(_delta: float) -> void:
	state_timer -= _delta
	if state_timer <= 0.0:
		state_machine.transition_to(nextState)

	# Pick a random direction to move in, pause randomly
	timer -= _delta
	if timer <= 0.0:
		wandering = not wandering
		if wandering:
			random_direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
			timer = randf_range(WANDER_TIME_SECONDS_MIN, WANDER_TIME_SECONDS_MAX)
		else:
			timer = randf_range(PAUSE_TIME_SECONDS_MIN, PAUSE_TIME_SECONDS_MAX)

	if wandering:
		enemy.absolute_velocity = random_direction * enemy.move_speed
	else:
		enemy.absolute_velocity = Vector2.ZERO