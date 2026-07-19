class_name Enemy
extends CharacterBody2D

const MAX_AGGRO_ENEMIES := 2

# Hits with no launch of their own still pop the target up by this much when it
# has to be knocked down anyway (a killing blow, or a re-hit while ragdolling)
const DEATH_LAUNCH := -260.0
const JUGGLE_LAUNCH := -300.0
const DEATH_KNOCKBACK_MIN := 260.0

@export var move_speed := 100.0
@export var player_ref: Player
@export var audio_stream_player: AudioStreamPlayer

@onready var ground_collider: CollisionShape2D = $CollisionShape2D
@onready var shadow: Sprite2D = $Shadow
@onready var game: Game = get_node("/root/Game") as Game
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Hurtbox = $AnimatedSprite2D/HurtBox
@onready var healthbar: ProgressBar = $Healthbar
@onready var state_machine: StateMachine = %StateMachine
@onready var hurt_state: EnemyHurtState = %EnemyHurtState
@onready var ragdoll_state: EnemyRagdollState = %EnemyRagdollState

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var absolute_velocity := Vector2.ZERO

# Altitude, faked the same way the player does it: negative is up, 0 is the floor.
# Rendered by offsetting the sprite, which carries the hurtbox up with it.
var z := 0.0
var z_velocity := 0.0
var is_dead := false

var _shadow_base_scale: Vector2
var _sprite_pivot: Vector2

func _ready() -> void:
	# Health (Healthbar.max_value) and sprite frames come from the enemy scene itself
	healthbar.value = healthbar.max_value
	_shadow_base_scale = shadow.scale
	# The sprite's origin sits at the bottom, so rotating the node alone would swing the body around
	# the bottom - define a pivot where the sprite's centre actually sits
	_sprite_pivot = sprite.offset * sprite.scale

func initialize(player: Player) -> void:
	player_ref = player

func _physics_process(_delta: float) -> void:
	velocity = IsometryUtils.scale_velocity(absolute_velocity)
	move_and_slide()

func _process(_delta: float) -> void:
	# Altitude plus shift that keeps the sprite's centre planted when it spins
	sprite.position = Vector2(0.0, z) + _sprite_pivot - _sprite_pivot.rotated(sprite.rotation)
	shadow.scale = _shadow_base_scale * IsometryUtils.scale_shadow_from(z)

func take_hit(hit: HitConfig, source: Node2D) -> void:
	if is_dead:
		return

	healthbar.value -= hit.damage
	var dir := Vector2(signf(position.x - source.position.x), 0.0)
	if dir.x == 0.0: # Directly on top of us; shove them the way the attacker faces
		dir.x = -1.0 if source.sprite.flip_h else 1.0

	if healthbar.value <= 0:
		is_dead = true
		healthbar.hide()
		# Corpses still fly. They despawn once the ragdoll settles.
		knock_down(
			dir * maxf(hit.knockback, DEATH_KNOCKBACK_MIN),
			hit.launch if hit.launch != 0.0 else DEATH_LAUNCH
		)
		game.incr_enemy_defeated_count()
		return

	# A ragdolling enemy can't drop back into ordinary hitstun mid-air, so any
	# hit that connects while it's down there keeps it airborne instead
	if hit.knockdown or state_machine.state == ragdoll_state:
		knock_down(dir * hit.knockback, hit.launch if hit.launch != 0.0 else JUGGLE_LAUNCH)
	else:
		state_machine.transition_to(hurt_state, {"dir": dir})

func knock_down(impulse: Vector2, launch: float) -> void:
	if state_machine.state == ragdoll_state:
		# Already ragdolling: relaunch in place rather than re-entering the state,
		# which would reset the altitude we're trying to add to
		ragdoll_state.relaunch(impulse, launch)
	else:
		state_machine.transition_to(ragdoll_state, {"impulse": impulse, "launch": launch})

func despawn() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
	tween.parallel().tween_property(shadow, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)

func get_sprite_size():
	return sprite.sprite_frames.get_frame_texture("default", 0).get_size() * sprite.scale

func is_aggroing() -> bool:
	return state_machine.state is EnemyApproachState or state_machine.state is EnemyAttackState

# Excludes self, so the answer holds whether claiming a slot or keeping one
func can_take_aggro_slot() -> bool:
	var others_aggroing := 0
	for other in get_parent().get_children():
		if other != self and is_instance_valid(other) and other is Enemy and other.is_aggroing():
			others_aggroing += 1
	return others_aggroing < MAX_AGGRO_ENEMIES

func play_hurt_sfx():
	var hurt_sfx = [GameVariables.hurt_1, GameVariables.hurt_2, GameVariables.hurt_3]
	var random_sfx = hurt_sfx.pick_random()
	audio_stream_player.stream = random_sfx
	audio_stream_player.play()
	
func play_attack_sfx():
	var attack_sfx = GameVariables.enemy_attack_sfx
	audio_stream_player.stream = attack_sfx
	audio_stream_player.play()
