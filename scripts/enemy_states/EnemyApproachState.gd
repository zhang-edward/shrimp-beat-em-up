# Represents the state where the enemy is chasing and attacking the player. 
class_name EnemyApproachState
extends EnemyState

const ATTACK_RANGE_X := 100.0
const ATTACK_RANGE_Y := 20.0
const ATTACK_COOLDOWN_SECONDS := 1.0
const STATE_DURATION_SECONDS := 10.0

@export var next_state: State
@export var attack_state: EnemyAttackState

var state_timer := 0.0 # Timer to track how long the enemy has been in the current state
var attack_timer := 0.0

func enter(_msg := {}) -> void:
	state_timer = STATE_DURATION_SECONDS

func update(_delta: float) -> void:
	var player = enemy.player_ref

	enemy.absolute_velocity.x = sign(player.global_position.x - enemy.global_position.x) * enemy.move_speed \
		if abs(player.global_position.x - enemy.global_position.x) > ATTACK_RANGE_X \
		else 0.0
	
	if enemy.absolute_velocity.x != 0:
		enemy.sprite.flip_h = enemy.absolute_velocity.x < 0

	enemy.absolute_velocity.y = sign(player.global_position.y - enemy.global_position.y) * enemy.move_speed \
		if abs(player.global_position.y - enemy.global_position.y) > ATTACK_RANGE_Y \
		else 0.0

	if abs(player.global_position.x - enemy.global_position.x) <= ATTACK_RANGE_X and \
		abs(player.global_position.y - enemy.global_position.y) <= ATTACK_RANGE_Y:
		enemy.absolute_velocity = Vector2.ZERO
		state_machine.transition_to(attack_state)
		

	state_timer -= _delta
	if state_timer <= 0.0:
		state_machine.transition_to(next_state)
