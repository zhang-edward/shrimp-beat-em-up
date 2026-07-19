class_name PlayerDashState
extends PlayerState

const DASH_VELOCITY = 1000
const DASH_DURATION = 0.3
var dash_timer
var damping_factor = 4.0
var prev_state: PlayerState

func enter(msg := {}) -> void:
	player.play_dash_sfx()
	prev_state = msg["prev_state"] as PlayerState
	player.sprite.play("move")
	dash_timer = DASH_DURATION
	player.z_velocity = 0
	player.velocity.x = - DASH_VELOCITY if player.sprite.flip_h else DASH_VELOCITY

func update(_delta) -> void:
	player.velocity.x *= exp(-damping_factor * _delta)
	dash_timer -= _delta
	if dash_timer <= 0:
		state_machine.transition_to(prev_state)
