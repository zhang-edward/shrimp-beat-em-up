class_name PlayerDeathState
extends PlayerState

@export var spawn_state: PlayerSpawnState

func enter(msg := {}) -> void:
	Engine.time_scale = 0.5
	player.sprite.modulate = Color(0, 0, 0, 0.75)
	await get_tree().create_timer(0.5).timeout

	Engine.time_scale = 1

	await animate_dead_body()
	await get_tree().create_timer(1.0).timeout

	state_machine.transition_to(spawn_state)

func exit():
	player.sprite.modulate = Color(1, 1, 1)

func animate_dead_body():
	var sprite = player.sprite
	var base = sprite.scale
	sprite.modulate = Color.WHITE

	var t := get_tree().create_tween()
	t.tween_callback(func(): sprite.play("dead"))
	t.parallel().tween_property(sprite, "scale", base * Vector2(1.05, 0.95), 0.05)
	t.tween_property(sprite, "scale", base * Vector2(0.98, 1.02), 0.05)
	t.tween_property(sprite, "scale", base, 0.05)

	await t.finished