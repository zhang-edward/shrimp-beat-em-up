class_name PlayerGrabbedState
extends PlayerState

"""
The player is shut inside the final boss's clasped hands: hidden from view, carried
wherever the hands go, and mashing attack to get back out.
"""

const ESCAPE_MASHES = 8

@export var fall_state: PlayerFallState

var _hand: Node2D
var _hand_sprite: Node2D
var _mashes_left: int

func enter(msg := {}) -> void:
	_hand = msg["hand"]
	_hand_sprite = _hand.get_node("Sprite")
	_mashes_left = ESCAPE_MASHES
	player.velocity = Vector2.ZERO
	player.z_velocity = 0.0
	# Inside the fist, so the hand's sprite is the only thing that should read
	player.sprite.hide()
	player.shadow.hide()

func exit() -> void:
	player.sprite.show()
	player.shadow.show()
	_hand = null
	_hand_sprite = null

func update(_delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		_mashes_left -= 1
		if _mashes_left <= 0:
			escape()

func physics_update(_delta: float) -> void:
	# Ride along with the hand: its ground position is ours, and however far it has
	# lifted its sprite is our altitude, so being let go drops us from that height
	player.velocity = Vector2.ZERO
	player.global_position = _hand.global_position
	player.z = _hand_sprite.position.y

# Mashed out under the player's own steam
func escape() -> void:
	release()
	player.grab_escaped.emit()

# Dropped by the hands, without crediting the player an escape
func release() -> void:
	state_machine.transition_to(fall_state)
