class_name EnemyHurtState
extends EnemyState

const BASE_KNOCKBACK := 100
const HITSTUN_SECONDS := 0.5

@export var default_state: State
var hitstun_timer = 0

func enter(msg := {}):
	var dir: Vector2 = msg["dir"] if msg.has("dir") else Vector2.ZERO
	enemy.absolute_velocity = dir.normalized() * BASE_KNOCKBACK
	hitstun_timer = HITSTUN_SECONDS

func update(delta: float) -> void:
	enemy.absolute_velocity *= 0.9
	enemy.sprite.play("hurt")

	hitstun_timer -= delta
	if hitstun_timer <= 0:
		state_machine.transition_to(default_state)

func exit() -> void:
	enemy.velocity = Vector2.ZERO
