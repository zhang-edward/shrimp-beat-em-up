class_name PlayerHurtState
extends PlayerState

const HITSTUN_SECONDS := 0.2

@export var move_state: PlayerMoveState
@export var fall_state: PlayerFallState

var t := 0.0

func enter(_msg := {}) -> void:
	player.play_hurt_sfx()
	player.sprite.play("hurt")
	t = HITSTUN_SECONDS
	player.sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.75).timeout
	player.sprite.modulate = Color(1, 1, 1)

func update(delta: float) -> void:
	t -= delta
	if t <= 0:
		if player.z < 0:
			state_machine.transition_to(fall_state)
		else:
			state_machine.transition_to(move_state)
