class_name EnemyEnterArenaState
extends EnemyState

@export var next_state: State
var fall_speed: float
const AUTO_FACE_PLAYER_RANGE = 200

func enter(_msg := {}) -> void:
	enemy.shadow.hide()
	enemy.ground_collider.disabled = true
	fall_speed = randf_range(enemy.move_speed, enemy.move_speed * 5)
	
func exit() -> void:
	enemy.shadow.show()
	enemy.ground_collider.disabled = false

func update(_delta: float) -> void:
	if enemy.global_position.y >= 165: # Top boundary of arena
		state_machine.transition_to(next_state)
	enemy.absolute_velocity.y = fall_speed
	animate()

func animate():
	if enemy.velocity.length_squared() > 0:
		enemy.sprite.play("move")
	else:
		enemy.sprite.play("default")

	if (enemy.player_ref.position - enemy.position).length() <= AUTO_FACE_PLAYER_RANGE:
		enemy.sprite.flip_h = enemy.position.x > enemy.player_ref.position.x
	elif enemy.velocity.x != 0:
		enemy.sprite.flip_h = enemy.velocity.x < 0
