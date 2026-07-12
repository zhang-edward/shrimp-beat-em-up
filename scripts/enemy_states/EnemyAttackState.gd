# Represents the state where the enemy is chasing and attacking the player. 
class_name EnemyAttackState
extends EnemyState

const ATTACK_RANGE_X := 100.0
const ATTACK_RANGE_Y := 20.0
const ATTACK_COOLDOWN_SECONDS := 1.0
const STATE_DURATION_SECONDS := 10.0

@export var hitbox_scene: PackedScene = preload("res://prefab/Hitbox.tscn")
@export var nextState: State

var state_timer := 0.0 # Timer to track how long the enemy has been in the current state
var attack_timer := 0.0

func enter(_msg := {}) -> void:
	state_timer = STATE_DURATION_SECONDS

func update(_delta: float) -> void:
	var player = enemy.playerRef

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
		# Attack player
		if attack_timer <= 0.0:
			attack_timer = ATTACK_COOLDOWN_SECONDS
			var hitbox = hitbox_scene.instantiate()
			enemy.add_child(hitbox)
			var sprite_size = enemy.get_sprite_size()
			var hitbox_offset = Vector2(-50, -sprite_size.y / 3) if enemy.sprite.flip_h else Vector2(50, -sprite_size.y / 3)
			hitbox.init(hitbox_offset, Vector2(64, 64), 0.25, Hitbox.CollideableTypes.Player, 10, enemy)
		else:
			attack_timer -= _delta

	state_timer -= _delta
	if state_timer <= 0.0:
		state_machine.transition_to(nextState)
