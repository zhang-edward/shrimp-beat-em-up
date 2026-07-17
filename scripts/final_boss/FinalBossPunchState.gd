class_name FinalBossPunchState
extends FinalBossState

const PUNCH_WINDUP_SECONDS = 1.0
const PUNCH_ACTIVE_SECONDS = 0.05
const PUNCH_RECOVERY_SECONDS = 0.5
const PUNCH_STARTING_Y = -800
const STATE_DURATION_SECONDS = 10

@export var next_state: FinalBossState
var timer := 0.0
var punching: Array[bool] = [false, false]
var hitbox_scene: PackedScene = preload("res://prefab/Hitbox.tscn")

func enter(_msg := {}) -> void:
	timer = STATE_DURATION_SECONDS
	controller.hand1.get_node("Sprite").play("fist")
	controller.hand2.get_node("Sprite").play("fist")
	punching = [false, false]

func update(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		if not punching[0] and not punching[1]:
			state_machine.transition_to(next_state)
		return
	if not punching[0]:
		# pick a random spot on the left side of the arena
		var targetPos = Vector2(randf_range(0, -600), randf_range(150, 350))
		controller.hand1.position = targetPos
		_punch(0)
	if not punching[1]:
		# pick a random spot on the right side of the arena
		var targetPos = Vector2(randf_range(0, 600), randf_range(150, 350))
		controller.hand2.position = targetPos
		_punch(1)
		

func _punch(idx: int):
	punching[idx] = true
	var hand_controller = controller.hand1 if idx == 0 else controller.hand2
	var sprite = hand_controller.get_node("Sprite")
	sprite.position.y = PUNCH_STARTING_Y
	var tween = controller.get_tree().create_tween()
	# Punch telegraph
	tween.set_parallel(false)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(sprite, "position:y", PUNCH_STARTING_Y + 300, 1.0)
	tween.tween_interval(PUNCH_WINDUP_SECONDS)

	# Punch 
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(sprite, "position:y", 0, 0.2)
	tween.tween_callback(_spawn_punch_hitbox.bind(hand_controller))
	tween.tween_interval(2)

	# Punch recovery
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "position:y", -800, PUNCH_WINDUP_SECONDS)

	# Random cooldown
	tween.tween_interval(randf_range(0, 1))
	tween.tween_callback(func(): punching[idx] = false)

func _spawn_punch_hitbox(hand_controller: Node2D):
	var hitbox = hitbox_scene.instantiate() as Hitbox
	hand_controller.add_child(hitbox)
	var hit_config = HitConfig.create(10, HitEffectRegistry.HIT_EFFECT_1)
	hitbox.init(Vector2.ZERO, Vector2(192, 48), PUNCH_ACTIVE_SECONDS, Hitbox.CollideableTypes.Player, hand_controller, hit_config)
