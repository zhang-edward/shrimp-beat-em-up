class_name BossEnterArenaState
extends BossState

@export var next_state: BossState
@export var y_stop_pos := 0
@export var fall_speed: float = 200.0

func enter(_msg := {}) -> void:
	boss.shadow.hide()
	
func update(_delta: float) -> void:
	boss.absolute_velocity.y = fall_speed
	if boss.global_position.y >= y_stop_pos:
		boss.absolute_velocity.y = 0
		boss.shadow.show()
		state_machine.transition_to(next_state, {})
