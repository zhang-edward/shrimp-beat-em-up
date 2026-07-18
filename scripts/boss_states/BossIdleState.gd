class_name BossIdleState
extends BossState

@export var attack_states: Array[BossState]
@export var idle_time_seconds_max := 5.0
@export var idle_time_seconds_min := 2.0
var timer := 0.0

func enter(msg := {}):
	timer = randf_range(idle_time_seconds_min, idle_time_seconds_max)
	boss.absolute_velocity = Vector2.ZERO
	boss.sprite.play("idle")
	
func update(_delta: float):
	timer -= _delta
	if timer <= 0.0:
		var random_state = attack_states.pick_random()
		if random_state != null:
			state_machine.transition_to(random_state, {})
