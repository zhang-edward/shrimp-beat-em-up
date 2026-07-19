class_name FinalBossGrabState
extends FinalBossState

const HAND_RESTING_Y = -800.0
const HAND_SPREAD_X = 200.0
const RELEASE_SPREAD_X = 160.0
const GRAB_RANGE_X = 90.0

const TELEGRAPH_SECONDS = 0.3
const DESCEND_SECONDS = 0.25
const WINDUP_SECONDS = 0.3
const CLASP_SECONDS = 0.3
const CLASP_HOLD_SECONDS = 1.0
const LIFT_SECONDS = 2.5
const RELEASE_SECONDS = 0.2
const RECOVERY_SECONDS = 0.6

@export var potential_next_states: Array[FinalBossState]

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

	await controller.move_face_to(FinalBossController.FacePos.BACK_WALL_RISEN, "determined_1")
	controller.play_emote("determined_3")

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

	controller.track_face_x(target.x)
	_tween.tween_interval(TELEGRAPH_SECONDS)

	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(_sprite1, "position:y", 0.0, DESCEND_SECONDS)
	_tween.parallel().tween_property(_sprite2, "position:y", 0.0, DESCEND_SECONDS)
	_tween.tween_interval(WINDUP_SECONDS)

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
	controller.play_grab_sfx()
	_hide_hand1()
	_sprite2.play("clasp")

	if _try_grab():
		_lift()
		return

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

func _carry_out_of_tank() -> void:
	var player := controller.player_ref
	player.kill()
	if player.num_lives > 0:
		player.release_from_grab()
		_retreat()

func _on_player_escaped() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_retreat()

func _retreat() -> void:
	_show_hand1()
	_sprite1.position.y = _sprite2.position.y
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
	_tween.tween_callback(func(): state_machine.transition_to(potential_next_states[randi() % potential_next_states.size()]))

# The clasp art draws both hands in one sprite, so hand1 hides to let hand2's clasp show
func _hide_hand1() -> void:
	_sprite1.hide()
	_hand1.get_node("Shadow").hide()
	_hand1.get_node("Sprite/HurtBox").monitorable = false

func _show_hand1() -> void:
	_sprite1.show()
	_hand1.get_node("Shadow").show()
	_hand1.get_node("Sprite/HurtBox").monitorable = true
