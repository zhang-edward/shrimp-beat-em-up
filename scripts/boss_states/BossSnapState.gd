class_name BossSnapState
extends BossState

@export var possible_next_states: Array[BossState]
@export var hitbox_scene: PackedScene

var claw_to_attack_with: LobsterBossClaw
var is_left: bool = false
var hitbox: Hitbox
var is_running: bool = false

var hit: HitConfig = HitConfig.create(25, HitEffectRegistry.HIT_EFFECT_1)

func enter(msg := {}) -> void:
	var lobster_boss = boss as LobsterBoss
	lobster_boss.reset_anims()
	choose_claw_to_attack_with()
	var tween = create_tween()
	var x_diff = -100 if is_left else 100
	var orig_x = claw_to_attack_with.global_position.x
	var windup_x = claw_to_attack_with.global_position.x + x_diff
	tween.tween_property(claw_to_attack_with, "global_position:x", windup_x, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var callable = Callable(self, "play_attack_animation").bind(orig_x)
	tween.finished.connect(callable)
	
func play_attack_animation(orig_x):
	await get_tree().create_timer(1.0).timeout
	var tween = create_tween()	
	var x_diff = 150 if is_left else -150
	var forward_x = orig_x + x_diff
	tween.tween_property(claw_to_attack_with, "global_position:x", forward_x, 0.2)
	boss.sprite.play("snap")
	claw_to_attack_with.sprite.play("snap")
	var callable = Callable(self, "on_animation_complete").bind(orig_x)
	claw_to_attack_with.sprite.animation_finished.connect(callable, CONNECT_ONE_SHOT)

func update(_delta: float) -> void:
	if hitbox == null:
		var sprite = claw_to_attack_with.sprite
		if sprite.animation == "snap" and sprite.frame == 1:
			hitbox = hitbox_scene.instantiate() as Hitbox
			claw_to_attack_with.sprite.add_child(hitbox)
			hitbox.init(Vector2(0, 0), Vector2(110, 100), 0.7, Hitbox.CollideableTypes.Player, boss, hit)

func on_animation_complete(orig_x):
	await get_tree().create_timer(0.5).timeout
	var tween = create_tween()
	tween.tween_property(claw_to_attack_with, "global_position:x", orig_x, 0.5)
	var on_complete = func _on_complete():
		var rand_state = possible_next_states.pick_random()
		state_machine.transition_to(rand_state)
	tween.finished.connect(on_complete)
	
func choose_claw_to_attack_with():
	var lobster_boss = boss as LobsterBoss
	if lobster_boss.left_claw.is_dead:
		is_left = false
		claw_to_attack_with = lobster_boss.right_claw
	elif lobster_boss.right_claw.is_dead:
		is_left = true
		claw_to_attack_with = lobster_boss.left_claw
	else:
		is_left = randi_range(0, 1) == 0
		claw_to_attack_with = lobster_boss.left_claw if is_left else lobster_boss.right_claw
