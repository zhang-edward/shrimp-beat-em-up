class_name EnemyWanderState
extends EnemyState

const ORBIT_SPEED_FACTOR := 1.1
const ARRIVAL_DISTANCE := 1.0 # Deadzone

const AGGRO_RETRY_SECONDS := 5.0

const WANDER_TIME_SECONDS_MAX := 8.0
const WANDER_TIME_SECONDS_MIN := 4.0
const PAUSE_TIME_SECONDS_MAX := 2.0
const PAUSE_TIME_SECONDS_MIN := 1.0
const STATE_DURATION_SECONDS := 10.0

@export var approach_state: State

var state_timer := 0.0 # Timer to track how long the enemy has been in the current state
var timer := 0.0
var wandering := false
var orbit_angle := 0.0
var orbit_direction := 1.0
var orbit_radius := 0
var orbit_speed_radians := 0.0

func enter(_msg := {}) -> void:
	state_timer = STATE_DURATION_SECONDS
	timer = randf_range(PAUSE_TIME_SECONDS_MIN, PAUSE_TIME_SECONDS_MAX)
	wandering = false

func update(_delta: float) -> void:
	state_timer -= _delta
	if state_timer <= 0.0:
		if enemy.can_take_aggro_slot():
			state_machine.transition_to(approach_state)
			return
		state_timer = AGGRO_RETRY_SECONDS

	# Alternate between chasing the orbiting point and pausing
	timer -= _delta
	if timer <= 0.0:
		wandering = not wandering
		if wandering:
			_start_new_orbit()
			timer = randf_range(WANDER_TIME_SECONDS_MIN, WANDER_TIME_SECONDS_MAX)
		else:
			timer = randf_range(PAUSE_TIME_SECONDS_MIN, PAUSE_TIME_SECONDS_MAX)

	if not wandering:
		enemy.absolute_velocity = Vector2.ZERO
		return

	# Orbit only advanced while moving
	orbit_angle = wrapf(orbit_angle + orbit_direction * orbit_speed_radians * _delta, -PI, PI)

	var to_point = _orbit_point() - enemy.global_position
	enemy.absolute_velocity = Vector2.ZERO if to_point.length() <= ARRIVAL_DISTANCE \
		else to_point.normalized() * enemy.move_speed
	
	animate()

func _start_new_orbit() -> void:
	orbit_radius = randi_range(240, 360)
	orbit_direction = 1.0 if randf() < 0.5 else -1.0
	orbit_angle = _enemy_orbit_angle()
	orbit_speed_radians = ORBIT_SPEED_FACTOR * enemy.move_speed / orbit_radius

# The point circling the player, on an ellipse
func _orbit_point() -> Vector2:
	return enemy.player_ref.global_position + Vector2(
		cos(orbit_angle) * orbit_radius,
		sin(orbit_angle) * orbit_radius * MovementUtils.DEPTH_SCALE * 0.5 # squashed on y axis so it reads as ellipse
	)

func _enemy_orbit_angle() -> float:
	var offset = enemy.global_position - enemy.player_ref.global_position
	return atan2(offset.y / MovementUtils.DEPTH_SCALE, offset.x)

func animate():
	if enemy.velocity.length_squared() > 0:
		enemy.sprite.play("move")
	else:
		enemy.sprite.play("default")

	if enemy.velocity.x != 0:
		enemy.sprite.flip_h = enemy.velocity.x < 0
