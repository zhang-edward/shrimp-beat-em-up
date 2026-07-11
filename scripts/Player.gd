class_name Player
extends CharacterBody2D

var speed = 200.0
const JUMP_VELOCITY = 500
var is_jumping = false

@export var ground_ref: Ground
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var direction_x = Input.get_axis("move_left", "move_right")
	velocity = Vector2(direction_x * speed, velocity.y)	
	if is_jumping:
		if get_slide_collision_count() > 0:
			is_jumping = false
			velocity.y = 0
		else:
			velocity.y += gravity * delta
	else:
		var direction_y = Input.get_axis("move_up", "move_down")
		if direction_y == 0:
			velocity.y = 0
			if Input.is_action_just_pressed("jump"):
				ground_ref.collision_shape.set_deferred("disabled", false)
				ground_ref.global_position.y = global_position.y
				is_jumping = true
				velocity.y = -JUMP_VELOCITY
		else:
			ground_ref.collision_shape.set_deferred("disabled", true)
			velocity = Vector2(velocity.x, direction_y * speed)
	move_and_slide()
