class_name BossHurtState
extends BossState

@export var idle_state: BossIdleState
@export var attack_states: Array[BossState]

var hitstun_timer = 0
var should_go_to_attack: bool = false

const BASE_KNOCKBACK := 50
const HITSTUN_SECONDS := 0.5

func enter(msg := {}):
	var dir: Vector2 = msg["dir"] if msg.has("dir") else Vector2.ZERO
	boss.absolute_velocity = dir.normalized() * BASE_KNOCKBACK
	hitstun_timer = HITSTUN_SECONDS
	should_go_to_attack = randi_range(0, 4) == 0

func update(delta: float) -> void:
	boss.absolute_velocity *= 0.9
	boss.sprite.play("hurt")
	
	if should_go_to_attack:
		var rand_state = attack_states.pick_random()
		if rand_state != null:
			state_machine.transition_to(rand_state, {})
	else:
		hitstun_timer -= delta
		if hitstun_timer <= 0:
			state_machine.transition_to(idle_state, {})

func exit() -> void:
	boss.velocity = Vector2.ZERO
