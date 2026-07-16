class_name Boss
extends CharacterBody2D

@export var hurt_state: BossHurtState
@export var death_state: BossDeathState

@onready var game = get_node("/root/Game") as Game
@onready var shadow: Sprite2D = $Shadow
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ground_collider: CollisionShape2D = $CollisionShape2D
@onready var state_machine: StateMachine = $StateMachine as StateMachine

var absolute_velocity := Vector2.ZERO
var boss_name: String
var max_health: int

func _ready():
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	velocity = IsometryUtils.scale_velocity(absolute_velocity)
	move_and_slide()
	
func has_super_armor():
	return state_machine.state is BossEnterArenaState or state_machine.state is BossDeathState

func take_hit(hit: HitConfig, source: Node2D) -> void:
	if has_super_armor():
		return
	var boss_health = game.boss_health as BossHealth
	boss_health.take_damage(hit.damage)
	if boss_health.get_health() == 0:
		state_machine.transition_to(death_state)
	else:
		var dir := Vector2(signf(position.x - source.position.x), 0.0)
		if dir.x == 0.0: # Directly on top of us; shove them the way the attacker faces
			dir.x = -1.0 if source.sprite.flip_h else 1.0
		state_machine.transition_to(hurt_state)
	
func get_sprite_size():
	return sprite.sprite_frames.get_frame_texture("idle", 0).get_size() * sprite.scale

func die():
	game.handle_boss_defeated()
