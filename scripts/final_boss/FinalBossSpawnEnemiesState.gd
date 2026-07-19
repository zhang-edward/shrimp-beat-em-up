class_name FinalBossSpawnEnemiesState
extends FinalBossState

const HAND_RESTING_Y := -800.0
const CLASP_POS := Vector2(0.0, 250.0)
const CLASP_HANDS_ALTITUDE := -300.0
const OPEN_SPREAD_X := 180.0
const SPILL_AREA := Vector2(200.0, -320.0)

const DESCEND_SECONDS := 0.4
const HOLD_SECONDS := 0.6
const OPEN_SECONDS := 0.25
const RECOVERY_SECONDS := 0.5

@export var next_state: FinalBossState
@export var enemy_scenes: Array[PackedScene] = []

var _tween: Tween
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
	controller.track_face_x(0)

	_hand1.position = CLASP_POS
	_hand2.position = CLASP_POS
	_hide_hand1()
	_sprite2.play("clasp")
	_sprite2.position.y = HAND_RESTING_Y

	_tween = controller.get_tree().create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(_sprite2, "position:y", CLASP_HANDS_ALTITUDE, DESCEND_SECONDS)
	_tween.tween_interval(HOLD_SECONDS)
	_tween.tween_callback(_open_hands)

func exit() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_show_hand1()

func _open_hands() -> void:
	_show_hand1()
	_sprite1.position.y = _sprite2.position.y
	_sprite1.play("open_hand")
	_sprite2.play("open_hand")

	_spawn_enemies()

	_tween = controller.get_tree().create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(_hand1, "position:x", CLASP_POS.x - OPEN_SPREAD_X, OPEN_SECONDS)
	_tween.parallel().tween_property(_hand2, "position:x", CLASP_POS.x + OPEN_SPREAD_X, OPEN_SECONDS)
	_tween.set_ease(Tween.EASE_IN)

	_tween.tween_property(_sprite1, "position:y", HAND_RESTING_Y, RECOVERY_SECONDS)
	_tween.parallel().tween_property(_sprite2, "position:y", HAND_RESTING_Y, RECOVERY_SECONDS)
	await _tween.finished
	_hand1.position.y = -800
	_hand2.position.y = -800

	await controller.play_emote("determined_1")
	state_machine.transition_to(next_state)

func _spawn_enemies() -> void:
	var folder := (controller.get_node("/root/Game") as Game).enemies_folder
	for scene in enemy_scenes:
		if scene == null:
			continue
		var enemy := scene.instantiate() as Enemy
		if enemy == null:
			continue
		enemy.player_ref = controller.player_ref
		folder.add_child(enemy)
		var offset := Vector2(randf_range(-SPILL_AREA.x, SPILL_AREA.x), SPILL_AREA.y)
		enemy.global_position = controller.to_global(CLASP_POS + offset)

# The clasp art draws both hands in one sprite, so hand1 hides to let hand2's clasp show
func _hide_hand1() -> void:
	_sprite1.hide()
	_hand1.get_node("Shadow").hide()
	_hand1.get_node("Sprite/HurtBox").monitorable = false

func _show_hand1() -> void:
	_sprite1.show()
	_hand1.get_node("Shadow").show()
	_hand1.get_node("Sprite/HurtBox").monitorable = true
