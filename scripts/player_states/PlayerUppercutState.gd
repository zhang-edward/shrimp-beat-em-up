class_name PlayerUppercutState
extends PlayerState

const AIR_MOVE_SPEED = 50.0
const JUMP_VELOCITY = -1500
const RECOVERY_TIME := 0.2

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var recovery_timer = 0

@export var move_state: PlayerMoveState
@export var fall_state: PlayerFallState
var hitbox_scene: PackedScene = preload("res://prefab/Hitbox.tscn")
# Launches them near-vertically: the juggle starter
var hit: HitConfig = HitConfig.create(10, HitEffectRegistry.HIT_EFFECT_2, PI / 4, 120.0, -800.0, true, 0.12)

func enter(_msg := {}) -> void:
	player.uppercut_used = true;
	recovery_timer = RECOVERY_TIME
	player.sprite.play("jump_uppercut")
	player.z_velocity = JUMP_VELOCITY

	var hitbox = hitbox_scene.instantiate()
	player.sprite.add_child(hitbox)
	var hitbox_offset = Vector2(-10, -10) if player.sprite.flip_h else Vector2(10, -10)
	hitbox.init(hitbox_offset, Vector2(24, 24), 0.25, Hitbox.CollideableTypes.Enemy, player, hit)

func physics_update(delta: float) -> void:
	var direction_x = Input.get_axis("move_left", "move_right")
	var direction_y = Input.get_axis("move_up", "move_down")
	player.velocity = Vector2(direction_x * AIR_MOVE_SPEED, direction_y * AIR_MOVE_SPEED)

	player.z += player.z_velocity * delta

	if player.z < 0:
		if player.z_velocity < -500:
			player.z_velocity += gravity * delta * 8
		else:
			player.z_velocity += gravity * delta
	else:
		player.z_velocity = 0
		player.z = 0

func update(delta: float) -> void:
	recovery_timer -= delta
	if recovery_timer <= 0:
		if player.z < 0:
			state_machine.transition_to(fall_state)
		else:
			state_machine.transition_to(move_state)
