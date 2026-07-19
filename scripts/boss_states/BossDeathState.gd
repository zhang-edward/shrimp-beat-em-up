class_name BossDeathState
extends BossState

func enter(_msg := {}) -> void:
	boss.sprite.play("hurt")
	var time_between_effect = 0.1
	for i in range(0, 35):
		spawn_effect_with_rand_delay(time_between_effect * i)
	var tween = create_tween()
	tween.tween_property(boss.sprite, "modulate:a", 0, 3.5).set_ease(Tween.EASE_OUT)
	tween.finished.connect(boss.die)
	
func spawn_effect_with_rand_delay(initial_delay):
	var rand_time = initial_delay + 0.25
	await get_tree().create_timer(rand_time).timeout
	var rand_x_diff = randi_range(-200, 200)
	var rand_y_diff = randi_range(-150, 150)
	boss.play_explode_sfx()
	spawn_effect(Vector2(boss.global_position.x + rand_x_diff, boss.global_position.y + rand_y_diff))
	
func spawn_effect(pos: Vector2):
	var config = EffectConfig.new()
	config.pos = pos
	config.anim = HitEffectRegistry.EXPLOSION
	EffectManager.spawn_effect(config)
