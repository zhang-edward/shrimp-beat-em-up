class_name BossEnterArenaState
extends BossState

@export var next_state: BossState
var fall_speed: float

func enter(_msg := {}) -> void:
	boss.shadow.hide()
	
func update(_delta: float) -> void:
	boss.absolute_velocity.y = 200
	if boss.global_position.y >= 300:
		boss.absolute_velocity.y = 0
		boss.shadow.show()
		state_machine.transition_to(next_state, {})
