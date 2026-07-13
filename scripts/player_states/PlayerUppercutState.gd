class_name PlayerUppercutState
extends PlayerState

const AIR_MOVE_SPEED = 50.0
const JUMP_VELOCITY = -500
const RECOVERY_TIME := 0.5

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var recovery_timer = 0

@export var move_state: PlayerMoveState
@export var jump_state: PlayerJumpState
var hitbox_scene: PackedScene = preload("res://prefab/Hitbox.tscn")

func enter(_msg := {}) -> void:
	recovery_timer = RECOVERY_TIME
	player.sprite.play("jump_uppercut")
	player.z_velocity = JUMP_VELOCITY

	var hitbox = hitbox_scene.instantiate()
	player.sprite.add_child(hitbox)
	var hitbox_offset = Vector2(-10, -10) if player.sprite.flip_h else Vector2(10, -10)
	hitbox.init(hitbox_offset, Vector2(24, 24), 0.25, Hitbox.CollideableTypes.Enemy, 10, player, HitEffectRegistry.HIT_EFFECT_1)

func physics_update(delta: float) -> void:
	var direction_x = Input.get_axis("move_left", "move_right")
	var direction_y = Input.get_axis("move_up", "move_down")
	player.velocity = Vector2(direction_x * AIR_MOVE_SPEED, direction_y * AIR_MOVE_SPEED)

	player.z += player.z_velocity * delta

	if player.z < 0:
		player.z_velocity += gravity * delta
	else:
		player.z_velocity = 0
		player.z = 0

func update(delta: float) -> void:
	recovery_timer -= delta
	if recovery_timer <= 0:
		if player.z < 0:
			state_machine.transition_to(jump_state, {"falling": true})
		else:
			state_machine.transition_to(move_state)

# func exit() -> void:
# 	player.z = 0
# 	player.z_velocity = 0
