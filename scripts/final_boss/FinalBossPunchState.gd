class_name FinalBossPunchState
extends FinalBossState

const PUNCH_WINDUP_SECONDS = 0.5
const PUNCH_ACTIVE_SECONDS = 0.05
const PUNCH_RECOVERY_SECONDS = 0.5
const PUNCH_STARTING_Y = -800

@export var next_state: FinalBossState
var punching: bool = false
var hitbox_scene: PackedScene = preload("res://prefab/Hitbox.tscn")
var _tweens: Array[Tween] = []

func enter(_msg := {}) -> void:
	punching = true
	await controller.move_face_to(FinalBossController.FacePos.BACK_WALL_RISEN, "determined_1")
	controller.play_emote("determined_3")

	controller.hand1.get_node("Sprite").play("fist")
	controller.hand2.get_node("Sprite").play("fist")
	punching = false

func exit() -> void:
	for tween in _tweens:
		if tween and tween.is_valid():
			tween.kill()
	_tweens.clear()


func update(delta: float) -> void:
	if not punching:
		punching = true
		var target_pos = Vector2(randf_range(-400, 400), randf_range(150, 350))
		var separation = randf_range(100, 250)
		controller.hand1.position.x = target_pos.x - separation
		controller.hand1.position.y = target_pos.y
		controller.hand2.position.x = target_pos.x + separation
		controller.hand2.position.y = target_pos.y
		controller.track_face_x(target_pos.x)
		_punch()
		
func _punch():
	_punch_hand(0)
	_punch_hand(1)

func _punch_hand(idx: int):
	var hand_controller = controller.hand1 if idx == 0 else controller.hand2
	var sprite = hand_controller.get_node("Sprite")
	sprite.position.y = PUNCH_STARTING_Y
	var tween = controller.get_tree().create_tween()
	_tweens.append(tween)

	# Punch telegraph
	tween.set_parallel(false)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(sprite, "position:y", PUNCH_STARTING_Y + 300, 1.0)
	tween.tween_interval(PUNCH_WINDUP_SECONDS)

	# Punch 
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(sprite, "position:y", 0, 0.1)
	tween.tween_callback(func(): controller.face_impact_bounce())
	tween.tween_callback(_spawn_punch_hitbox.bind(hand_controller))
	tween.tween_interval(2)

	# Punch recovery
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "position:y", -800, PUNCH_WINDUP_SECONDS)

	# Random cooldown
	tween.tween_interval(1.0)
	tween.tween_callback(func(): punching = false)
	if idx == 0:
		tween.tween_callback(func(): state_machine.transition_to(next_state))


func _spawn_punch_hitbox(hand_controller: Node2D):
	controller.play_punch_sfx()
	var hitbox = hitbox_scene.instantiate() as Hitbox
	hand_controller.add_child(hitbox)
	var hit_config = HitConfig.create(40, HitEffectRegistry.HIT_EFFECT_1)
	hitbox.init(Vector2.ZERO, Vector2(192, 48), PUNCH_ACTIVE_SECONDS, Hitbox.CollideableTypes.Player, hand_controller, hit_config)
	ScreenShake.shake_vertical(20, 0.5, 10)
