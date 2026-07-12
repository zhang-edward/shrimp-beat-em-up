class_name Player
extends CharacterBody2D

var speed = 200.0
const JUMP_VELOCITY = 500
var is_jumping = false

@onready var sprite = $Sprite2D

@export var healthbar: ProgressBar
# @export var ground_ref: Ground
@export var hitbox_scene: PackedScene = preload("res://prefab/Hitbox.tscn")

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var z_velocity = 0.0
var z = 0.0 # altitude

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
	var direction_y = Input.get_axis("move_up", "move_down")
	velocity = Vector2(direction_x * speed, direction_y * speed)

	if direction_x != 0:
		sprite.flip_h = direction_x < 0

	if is_jumping:
		if z < 0:
			z_velocity += gravity * delta
		else:
			z = 0
			z_velocity = 0
			is_jumping = false
	if z == 0 and Input.is_action_just_pressed("jump"):
		is_jumping = true
		z_velocity = - JUMP_VELOCITY

	z += z_velocity * delta
	velocity = MovementUtils.scale_velocity(velocity)
	sprite.position.y = z
	print(z)
	move_and_slide()

func damage(amount: int):
	healthbar.value -= amount
