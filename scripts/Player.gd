class_name Player
extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = %StateMachine
@onready var shadow: Sprite2D = $Shadow
@export var healthbar: ProgressBar

var z_velocity = 0.0
var z = 0.0 # altitude
var _shadow_base_scale: Vector2

func _ready() -> void:
	sprite.play("default")
	_shadow_base_scale = shadow.scale
	pass
	
func _process(_delta: float) -> void:
	# animation
	sprite.position.y = z
	if velocity.x != 0 and state_machine.state is not PlayerJumpSlamState:
		sprite.flip_h = velocity.x < 0
	shadow.scale = _shadow_base_scale * IsometryUtils.scale_shadow_from(z)

func _physics_process(_delta: float) -> void:
	velocity = IsometryUtils.scale_velocity(velocity)
	move_and_slide()

func damage(amount: int):
	healthbar.value -= amount

func get_sprite_size():
	return sprite.sprite_frames.get_frame_texture("default", 0).get_size() * sprite.scale
