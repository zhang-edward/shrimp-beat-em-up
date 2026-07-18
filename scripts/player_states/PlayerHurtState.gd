class_name PlayerHurtState
extends PlayerState

@export var move_state: PlayerMoveState

func enter(msg := {}) -> void:
	player.sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.75).timeout
	player.sprite.modulate = Color(1, 1, 1)
	state_machine.transition_to(move_state)
