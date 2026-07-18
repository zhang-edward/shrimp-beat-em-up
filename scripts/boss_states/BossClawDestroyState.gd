class_name BossClawDestroyState
extends BossState

@export var death_state: BossDeathState
var claw_destroyed

func enter(msg := {}) -> void:
	claw_destroyed = msg["claw_destroyed"] as LobsterBossClaw if msg.has("claw_destroyed") else null
	if claw_destroyed != null:
		var time_between_effect = 0.1
		for i in range(0, 35):
			spawn_effect_with_rand_delay(time_between_effect * i)
		var tween = create_tween()
		tween.tween_property(claw_destroyed.sprite, "modulate:a", 0, 3.5).set_ease(Tween.EASE_OUT)
		tween.finished.connect(check_both_dead)

func spawn_effect_with_rand_delay(initial_delay):
	var rand_time = initial_delay + 0.25
	await get_tree().create_timer(rand_time).timeout
	var rand_x_diff = randi_range(-200, 200)
	var rand_y_diff = randi_range(-150, 150)
	spawn_effect(Vector2(claw_destroyed.global_position.x + rand_x_diff, claw_destroyed.global_position.y + rand_y_diff))
	
func spawn_effect(pos: Vector2):
	var config = EffectConfig.new()
	config.pos = pos
	config.anim = HitEffectRegistry.HIT_EFFECT_1
	EffectManager.spawn_effect(config)

func check_both_dead():
	var lobster_boss = boss as LobsterBoss
	if lobster_boss.left_claw.is_dead and lobster_boss.right_claw.is_dead:
		state_machine.transition_to(death_state)
