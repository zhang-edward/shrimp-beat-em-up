class_name BossSlamState
extends BossState

@export var possible_next_states: Array[BossState]
@export var hitbox_scene: PackedScene

var claw_to_attack_with: LobsterBossClaw
var is_left: bool = false
var hitbox: Hitbox

var hit: HitConfig = HitConfig.create(30, HitEffectRegistry.HIT_EFFECT_1)

func enter(msg := {}) -> void:
	var lobster_boss = boss as LobsterBoss
	lobster_boss.reset_anims()
	choose_claw_to_attack_with()
	claw_to_attack_with.sprite.play("slam")
	var tween = create_tween()
	var orig_y = claw_to_attack_with.global_position.y
	var windup_y = claw_to_attack_with.global_position.y - 150
	lobster_boss.play_windup_sfx()
	tween.tween_property(claw_to_attack_with, "global_position:y", windup_y, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var callable = Callable(self, "play_attack_animation").bind(orig_y)
	tween.finished.connect(callable)

func play_attack_animation(orig_y):
	await get_tree().create_timer(0.25).timeout
	var tween = create_tween()
	var forward_y = orig_y + 55
	tween.tween_property(claw_to_attack_with, "global_position:y", forward_y, 0.2)
	if hitbox == null:
		hitbox = hitbox_scene.instantiate() as Hitbox
		claw_to_attack_with.sprite.add_child(hitbox)
		hitbox.init(Vector2(0, 0), Vector2(110, 100), 0.3, Hitbox.CollideableTypes.Player, boss, hit)
	var callable = Callable(self, "on_animation_complete").bind(orig_y)
	tween.finished.connect(callable)

func on_animation_complete(orig_y):
	var lobster_boss = boss as LobsterBoss	
	lobster_boss.play_slam_sfx()
	ScreenShake.shake_vertical(20, 0.5, 10)
	
	# Spawn dust under the claw that was slammed
	var dust_pos_x = claw_to_attack_with.global_position.x - 225
	for i in range(0, 15):
		dust_pos_x += randi_range(20, 25)
		_spawn_dust(Vector2(dust_pos_x, claw_to_attack_with.global_position.y + 10))
	await get_tree().create_timer(0.5).timeout
	var tween = create_tween()
	tween.tween_property(claw_to_attack_with, "global_position:y", orig_y, 0.5)
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
	

func _spawn_dust(position) -> void:
	print("Spawning dust!")
	var config := EffectConfig.new()
	config.pos = position
	config.anim = HitEffectRegistry.DUST
	EffectManager.spawn_effect(config)
