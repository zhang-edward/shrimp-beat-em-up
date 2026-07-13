class_name EffectManager
extends Node2D

static var instance: EffectManager
static var _effect_scene: PackedScene = preload("res://prefab/Effect.tscn")

func _ready() -> void:
	if instance == null:
		instance = self
	else:
		printerr("Multiple Effect Manager instances!")
		queue_free()

static func spawn_effect(config: EffectConfig):
	var effect: Effect = _effect_scene.instantiate()
	instance.add_child(effect)
	effect.position = config.pos + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	effect.sprite_frames = config.anim
	effect.rotation = randf_range(0, TAU)
	effect.scale *= randf_range(0.9, 1.1)
	effect.play()
