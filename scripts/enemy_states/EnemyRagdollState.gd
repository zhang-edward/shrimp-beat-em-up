class_name EnemyRagdollState
extends EnemyState

"""
Knocked-down enemy: a physics object that tumbles across the floor plane, bounces
off the screen edges, and bowls over other enemies.

Not a RigidBody2D on purpose. Screen-Y is a depth axis here (squashed by
IsometryUtils.DEPTH_SCALE) and altitude is faked in Enemy.z, so Godot's 2D gravity
would pull bodies toward the front of the tank instead of down. We integrate the
three axes ourselves and let move_and_slide() handle only the floor-plane collisions.
"""

enum Phase {AIRBORNE, SLIDING, DOWNED}

@export var approach_state: EnemyState
@export var wander_state: EnemyState

@export_group("Physics")
# Ragdolls fall faster than the project gravity, so hangtime doesn't drag
@export var gravity_scale := 1.0
# Fraction of altitude speed kept per floor bounce
@export var floor_restitution := 0.45
# Fraction of floor-plane speed kept when bouncing off a wall...
@export var wall_restitution := 0.6
# ...and when hitting the floor
@export var floor_skid_retention := 0.8
@export var air_drag := 40.0
@export var ground_friction := 400.0
# Below this altitude speed, stop bouncing and start sliding
@export var min_bounce_speed := 300.0
# Below this floor speed, stop sliding and lie down
@export var settle_speed := 40.0

@export_group("Timing")
@export var downed_seconds := 0.5

@export_group("Chaining")
# A ragdoll has to be moving at least this fast to knock over an enemy it slams into
@export var chain_min_speed := 220.0
# Fraction of its speed handed to that enemy
@export var chain_transfer := 0.6
@export var chain_launch := -220.0

# Keeps bodies from tumbling past the visible screen edge
const WALL_MARGIN := 40.0
const SPIN_SPEED := TAU * 2

var phase: Phase
var spin := 0.0
var downed_timer := 0.0
# Enemies already bowled over by the current launch, so two ragdolls touching can't relaunch each other 
var _chained := {}

func enter(msg := {}) -> void:
	relaunch(msg.get("impulse", Vector2.ZERO), msg.get("launch", 0.0))

# Applied on a fresh knockdown, and again on every hit that lands mid-ragdoll
func relaunch(impulse: Vector2, launch: float) -> void:
	enemy.absolute_velocity = impulse
	enemy.z_velocity = launch
	_chained.clear()
	spin = SPIN_SPEED * (1.0 if impulse.x >= 0.0 else -1.0)
	enemy.play_hit_sfx()
	enemy.sprite.play("hurt")
	# Reset hurtbox if previously lying down
	if not enemy.is_dead:
		enemy.hurtbox.set_deferred("monitorable", true)
	_enter_phase(Phase.AIRBORNE)

func physics_update(delta: float) -> void:
	match phase:
		Phase.AIRBORNE:
			enemy.z_velocity += enemy.gravity * gravity_scale * delta
			enemy.z += enemy.z_velocity * delta
			enemy.absolute_velocity = enemy.absolute_velocity.move_toward(Vector2.ZERO, air_drag * delta)
			enemy.sprite.rotation += spin * delta
			if enemy.z >= 0.0 and enemy.z_velocity > 0.0:
				_land()
		Phase.SLIDING:
			enemy.absolute_velocity = enemy.absolute_velocity.move_toward(Vector2.ZERO, ground_friction * delta)
			if enemy.absolute_velocity.length() <= settle_speed:
				enemy.absolute_velocity = Vector2.ZERO
				_enter_phase(Phase.DOWNED)
		_:
			enemy.absolute_velocity = Vector2.ZERO

	if phase == Phase.AIRBORNE or phase == Phase.SLIDING:
		_bounce_off_screen_edges()
		_bowl_over_other_enemies()

func update(delta: float) -> void:
	if phase == Phase.DOWNED:
		downed_timer -= delta
		if downed_timer <= 0.0:
			state_machine.transition_to(approach_state if enemy.can_take_aggro_slot() else wander_state)

func _enter_phase(next_phase: Phase) -> void:
	phase = next_phase
	match phase:
		Phase.SLIDING:
			enemy.sprite.rotation = 0.0
		Phase.DOWNED:
			downed_timer = downed_seconds
			# Downed enemies are safe until they're back in play
			enemy.hurtbox.set_deferred("monitorable", false)
			if enemy.is_dead:
				enemy.despawn()

func _land() -> void:
	enemy.z = 0.0
	_spawn_dust()

	if enemy.z_velocity >= min_bounce_speed:
		enemy.z_velocity *= -floor_restitution
		enemy.absolute_velocity *= floor_skid_retention
		Hitstop.freeze([enemy], 0.04)
		return

	enemy.z_velocity = 0.0
	_enter_phase(Phase.SLIDING)

# The left/right walls are the screen itself, not level geometry, so bodies can't
# tumble out of view. The camera rides the player, so this plane moves; only ever
# reflect a body that's travelling outward, otherwise a body the camera sweeps past
# would rattle against the edge.
func _bounce_off_screen_edges() -> void:
	var camera := enemy.get_viewport().get_camera_2d()
	if camera == null:
		return

	var half_extents := enemy.get_viewport_rect().size * 0.5 / camera.zoom
	# get_screen_center_position() accounts for the camera's smoothing and limits
	var bounds := Rect2(camera.get_screen_center_position() - half_extents, half_extents * 2.0).grow(-WALL_MARGIN)

	if enemy.global_position.x < bounds.position.x and enemy.absolute_velocity.x < 0.0:
		enemy.global_position.x = bounds.position.x
		enemy.absolute_velocity.x *= -wall_restitution
		_on_wall_hit()
	elif enemy.global_position.x > bounds.end.x and enemy.absolute_velocity.x > 0.0:
		enemy.global_position.x = bounds.end.x
		enemy.absolute_velocity.x *= -wall_restitution
		_on_wall_hit()

func _bowl_over_other_enemies() -> void:
	var speed := enemy.absolute_velocity.length()
	if speed < chain_min_speed:
		return

	for i in enemy.get_slide_collision_count():
		var other := enemy.get_slide_collision(i).get_collider()
		if other is not Enemy or _chained.has(other):
			continue

		_chained[other] = true
		var offset: Vector2 = other.global_position - enemy.global_position
		var dir := Vector2(offset.x, offset.y / IsometryUtils.DEPTH_SCALE).normalized()
		if dir == Vector2.ZERO:
			dir = enemy.absolute_velocity.normalized()

		other.knock_down(dir * speed * chain_transfer, chain_launch)
		enemy.absolute_velocity *= 1.0 - (chain_transfer / 2.0)
		Hitstop.freeze([enemy, other], 0.06)
		_spawn_dust()

func _on_wall_hit() -> void:
	spin = - spin
	_spawn_dust()
	Hitstop.freeze([enemy], 0.04)

func _spawn_dust() -> void:
	var config := EffectConfig.new()
	config.pos = enemy.global_position
	config.anim = HitEffectRegistry.HIT_EFFECT_2
	EffectManager.spawn_effect(config)

func exit() -> void:
	enemy.absolute_velocity = Vector2.ZERO
	enemy.z = 0.0
	enemy.z_velocity = 0.0
	enemy.sprite.rotation = 0.0
	enemy.hurtbox.set_deferred("monitorable", true)
