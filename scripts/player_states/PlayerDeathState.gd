class_name PlayerDeathState
extends PlayerState

@export var spawn_state: PlayerSpawnState

func enter(msg := {}) -> void:
	player.sprite.modulate = Color(0, 0, 0, 0.75)
	await get_tree().create_timer(0.5).timeout
	state_machine.transition_to(spawn_state)

func exit():
	player.sprite.modulate = Color(1, 1, 1)
