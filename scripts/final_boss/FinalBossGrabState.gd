class_name FinalBossGrabState
extends FinalBossState

"""
Both hands drop into the tank open, on either side of where the player was standing,
then clap shut. A player caught in the clasp is carried up and out of the tank unless
they mash their way free first.
"""

const HAND_RESTING_Y = -800.0 # altitude; above the camera's view, so only the shadow reads
const HAND_SPREAD_X = 200.0 # how far to either side of the target the hands open
const RELEASE_SPREAD_X = 160.0 # how far apart the hands spring once they let go
const GRAB_RANGE_X = 90.0 # how near the clasp the player has to be to get caught

const TELEGRAPH_SECONDS = 0.3
const DESCEND_SECONDS = 0.25
const WINDUP_SECONDS = 0.3
const CLASP_SECONDS = 0.3
const CLASP_HOLD_SECONDS = 1.0
const LIFT_SECONDS = 2.5
const RELEASE_SECONDS = 0.2
const RECOVERY_SECONDS = 0.6

@export var next_state: FinalBossState

var _tween: Tween
var _clasp_x: float
var _lane_y: float
var _hand1: Node2D
var _hand2: Node2D
var _sprite1: AnimatedSprite2D
var _sprite2: AnimatedSprite2D

func enter(_msg := {}) -> void:
	_hand1 = controller.hand1
	_hand2 = controller.hand2
	_sprite1 = _hand1.get_node("Sprite")
	_sprite2 = _hand2.get_node("Sprite")

	# Commit to where the player is standing now - player has until the clasp to leave
	var target := controller.to_local(controller.player_ref.global_position)
	_clasp_x = target.x
	_lane_y = target.y

	_hand1.position = Vector2(_clasp_x - HAND_SPREAD_X, _lane_y)
	_hand2.position = Vector2(_clasp_x + HAND_SPREAD_X, _lane_y)
	_sprite1.position.y = HAND_RESTING_Y
	_sprite2.position.y = HAND_RESTING_Y
	_sprite1.play("open_hand")
	_sprite2.play("open_hand")

	_tween = controller.get_tree().create_tween()

	# Telegraph: the hands are above the camera's view, so only their two shadows show
	_tween.tween_interval(TELEGRAPH_SECONDS)

	# Both hands drop into view, open, and hang there long enough to be run away from
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(_sprite1, "position:y", 0.0, DESCEND_SECONDS)
	_tween.parallel().tween_property(_sprite2, "position:y", 0.0, DESCEND_SECONDS)
	_tween.tween_interval(WINDUP_SECONDS)

	# Clap shut
	_tween.set_ease(Tween.EASE_IN)
	_tween.tween_property(_hand1, "position:x", _clasp_x, CLASP_SECONDS)
	_tween.parallel().tween_property(_hand2, "position:x", _clasp_x, CLASP_SECONDS)
	_tween.tween_callback(_clasp)

func exit() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	var player := controller.player_ref
	if player.grab_escaped.is_connected(_on_player_escaped):
		player.grab_escaped.disconnect(_on_player_escaped)
	_show_hand1()

func _clasp() -> void:
	# The clasp art has both hands in the one sprite, so hand1 steps aside to let it show
	_hide_hand1()
	_sprite2.play("clasp")

	if _try_grab():
		_lift()
		return

	# Closed on nothing but water
	_tween = controller.get_tree().create_tween()
	_tween.tween_interval(CLASP_HOLD_SECONDS)
	_tween.tween_callback(_retreat)

func _try_grab() -> bool:
	var player := controller.player_ref
	var pos := controller.to_local(player.global_position)
	if absf(pos.x - _clasp_x) > GRAB_RANGE_X:
		return false
	if absf(pos.y - _lane_y) > IsometryUtils.Y_AXIS_HIT_RANGE:
		return false
	return player.try_grab(_hand2)

func _lift() -> void:
	controller.player_ref.grab_escaped.connect(_on_player_escaped)

	_tween = controller.get_tree().create_tween()
	_tween.tween_interval(CLASP_HOLD_SECONDS)
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.tween_property(_sprite2, "position:y", HAND_RESTING_Y, LIFT_SECONDS)
	_tween.tween_callback(_carry_out_of_tank)

# The lift finished with the player still inside - clear the rim of the tank
func _carry_out_of_tank() -> void:
	var player := controller.player_ref
	player.kill()
	player.release_from_grab()
	_retreat()

func _on_player_escaped() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_retreat()

func _retreat() -> void:
	_show_hand1()
	_sprite1.position.y = _sprite2.position.y # hand1 rejoins wherever the clasp got to
	_sprite1.play("open_hand")
	_sprite2.play("open_hand")

	_tween = controller.get_tree().create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(_hand1, "position:x", _clasp_x - RELEASE_SPREAD_X, RELEASE_SECONDS)
	_tween.parallel().tween_property(_hand2, "position:x", _clasp_x + RELEASE_SPREAD_X, RELEASE_SECONDS)

	_tween.set_ease(Tween.EASE_IN)
	_tween.tween_property(_sprite1, "position:y", HAND_RESTING_Y, RECOVERY_SECONDS)
	_tween.parallel().tween_property(_sprite2, "position:y", HAND_RESTING_Y, RECOVERY_SECONDS)
	print("done")
	_tween.tween_callback(func(): state_machine.transition_to(next_state))

# Hand1 is folded into the clasp sprite
func _hide_hand1() -> void:
	_sprite1.hide()
	_hand1.get_node("Shadow").hide()
	_hand1.get_node("Sprite/HurtBox").monitorable = false

func _show_hand1() -> void:
	_sprite1.show()
	_hand1.get_node("Shadow").show()
	_hand1.get_node("Sprite/HurtBox").monitorable = true
