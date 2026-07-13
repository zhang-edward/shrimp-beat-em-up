class_name PropWithRandomizedAnimation
extends AnimatedSprite2D

func _ready() -> void:
	var speed = randf_range(0.5, 1)
	play("default", speed)