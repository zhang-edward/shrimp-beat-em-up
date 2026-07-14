class_name Boss
extends CharacterBody2D

@onready var shadow: Sprite2D = $Shadow
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ground_collider: CollisionShape2D = $CollisionShape2D

var absolute_velocity := Vector2.ZERO

func _ready():
	sprite.play("idle")

# func _process(delta: float) -> void:
func _physics_process(delta: float) -> void:
	velocity = IsometryUtils.scale_velocity(absolute_velocity)
	move_and_slide()
