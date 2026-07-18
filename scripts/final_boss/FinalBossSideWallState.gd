class_name FinalBossSideWallState
extends FinalBossState

const TIME_SPEND_ON_SIDE_WALL_SECONDS = 5.0

@export var potential_next_states: Array[FinalBossState]
var t := 0.0
var leaving := false

func enter(_msg := {}) -> void:
	var side = FinalBossController.FacePos.SIDE_RIGHT if randf() < 0.5 else FinalBossController.FacePos.SIDE_LEFT
	controller.move_face_to(side, "")
	t = TIME_SPEND_ON_SIDE_WALL_SECONDS

func update(delta: float) -> void:
	t -= delta
	if t <= 0 and not leaving:
		leaving = true
		state_machine.transition_to(potential_next_states[randi() % potential_next_states.size()])

func exit() -> void:
	leaving = false
