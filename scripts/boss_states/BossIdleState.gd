class_name BossIdleState
extends BossState

@export var bite_state: BossBiteState
@export var chomp_lunge_state: BossChompLungeState

const IDLE_TIME_SECONDS_MAX := 5.0
const IDLE_TIME_SECONDS_MIN := 2.0
var timer := 0.0

func enter(msg := {}):
	timer = randf_range(IDLE_TIME_SECONDS_MIN, IDLE_TIME_SECONDS_MAX)
	boss.absolute_velocity = Vector2.ZERO
	boss.sprite.play("idle")
	
func update(_delta: float):
	timer -= _delta
	if timer <= 0.0:
		var random_state = [bite_state, chomp_lunge_state].pick_random()
		state_machine.transition_to(random_state, {})
