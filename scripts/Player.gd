class_name Player
extends CharacterBody2D

var speed = 200.0
const JUMP_VELOCITY = 500
var is_jumping = false

@onready var sprite = $Sprite2D

@export var healthbar: ProgressBar
@export var ground_ref: Ground
@export var hitbox_scene: PackedScene = preload("res://prefab/Hitbox.tscn")

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		var hitbox = hitbox_scene.instantiate()
		add_child(hitbox)
		var hitbox_offset = Vector2(-50, 0) if sprite.flip_h else Vector2(50, 0)
		hitbox.init(hitbox_offset, Vector2(64, 64), 0.25, Hitbox.CollideableTypes.Enemy, 10)

func _physics_process(delta: float) -> void:
	var direction_x = Input.get_axis("move_left", "move_right")
	velocity = Vector2(direction_x * speed, velocity.y)
	if direction_x != 0:
		sprite.flip_h = direction_x < 0
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
				velocity.y = - JUMP_VELOCITY
		else:
			ground_ref.collision_shape.set_deferred("disabled", true)
			velocity = Vector2(velocity.x, direction_y * speed)
	move_and_slide()

func damage(amount: int):
	healthbar.value -= amount
