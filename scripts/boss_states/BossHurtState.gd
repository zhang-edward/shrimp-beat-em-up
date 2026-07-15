class_name BossHurtState
extends BossState

@export var idle_state: BossIdleState
var hitstun_timer = 0

const BASE_KNOCKBACK := 100
const HITSTUN_SECONDS := 0.5

func enter(msg := {}):
	var dir: Vector2 = msg["dir"] if msg.has("dir") else Vector2.ZERO
	boss.absolute_velocity = dir.normalized() * BASE_KNOCKBACK
	hitstun_timer = HITSTUN_SECONDS

func update(delta: float) -> void:
	boss.absolute_velocity *= 0.9
	boss.sprite.play("hurt")

	hitstun_timer -= delta
	if hitstun_timer <= 0:
		state_machine.transition_to(idle_state, {})

func exit() -> void:
	boss.velocity = Vector2.ZERO
