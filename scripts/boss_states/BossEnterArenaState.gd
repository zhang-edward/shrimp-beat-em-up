class_name BossEnterArenaState
extends BossState

@export var next_state: BossState
var fall_speed: float
const AUTO_FACE_PLAYER_RANGE = 200

func enter(_msg := {}) -> void:
	boss.ground_collider.disabled = true
	boss.shadow.hide()
	
func update(_delta: float) -> void:
	boss.absolute_velocity.y = 200
	if boss.global_position.y >= 125: # Top boundary of arena
		boss.absolute_velocity.y = 0
		boss.ground_collider.disabled = false
		boss.shadow.show()
		state_machine.transition_to(next_state, {})
