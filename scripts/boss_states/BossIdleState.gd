class_name BossIdleState
extends BossState

@export var bite_state: BossBiteState

const IDLE_TIME_SECONDS_MAX := 5.0
const IDLE_TIME_SECONDS_MIN := 2.0
var timer := 0.0

func enter(msg := {}):
	print("Enter idle state")
	timer = randf_range(IDLE_TIME_SECONDS_MIN, IDLE_TIME_SECONDS_MAX)
	print(timer)
	boss.absolute_velocity = Vector2.ZERO
	boss.sprite.play("idle")
	
func update(_delta: float):
	timer -= _delta
	if timer <= 0.0:
		print("Go to bite state from idle!")
		state_machine.transition_to(bite_state, {})
