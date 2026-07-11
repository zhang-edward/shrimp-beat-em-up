extends Label

@export var state_machine: StateMachine

func _process(_delta: float) -> void:
	if state_machine:
		text = state_machine.state.name
