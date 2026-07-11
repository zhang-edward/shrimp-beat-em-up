# Represents the state where the enemy is chasing and attacking the player. 
class_name AttackState
extends State

const ATTACK_RANGE_X := 100.0
const ATTACK_RANGE_Y := 20.0
const ATTACK_COOLDOWN_SECONDS := 1.0
const STATE_DURATION_SECONDS := 10.0

@export var nextState: State

var state_timer := 0.0 # Timer to track how long the enemy has been in the current state
var attack_timer := 0.0

func enter(_msg := {}) -> void:
	state_timer = STATE_DURATION_SECONDS

func update(_delta: float) -> void:
	var enemy = entity as Enemy
	var player = enemy.playerRef

	enemy.velocity.x = sign(player.global_position.x - enemy.global_position.x) * enemy.move_speed \
		if abs(player.global_position.x - enemy.global_position.x) > ATTACK_RANGE_X \
		else 0.0

	enemy.velocity.y = sign(player.global_position.y - enemy.global_position.y) * enemy.move_speed \
		if abs(player.global_position.y - enemy.global_position.y) > ATTACK_RANGE_Y \
		else 0.0

	if abs(player.global_position.x - enemy.global_position.x) <= ATTACK_RANGE_X and \
		abs(player.global_position.y - enemy.global_position.y) <= ATTACK_RANGE_Y:
		enemy.velocity = Vector2.ZERO
		# Attack player
		if attack_timer <= 0.0:
			attack_timer = ATTACK_COOLDOWN_SECONDS
			print(enemy, " attacking player!")
		else:
			attack_timer -= _delta

	state_timer -= _delta
	if state_timer <= 0.0:
		state_machine.transition_to(nextState)
