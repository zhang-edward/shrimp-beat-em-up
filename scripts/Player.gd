class_name Player
extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var healthbar: ProgressBar

var z_velocity = 0.0
var z = 0.0 # altitude

func _ready() -> void:
	sprite.play("default")
	pass
	
func _process(_delta: float) -> void:
	# animation
	sprite.position.y = z
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

func _physics_process(_delta: float) -> void:
	velocity = MovementUtils.scale_velocity(velocity)
	move_and_slide()

func damage(amount: int):
	healthbar.value -= amount
