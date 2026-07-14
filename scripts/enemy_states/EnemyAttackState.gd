class_name EnemyAttackState
extends EnemyState

enum Phase {WINDUP, ACTIVE, RECOVERY}

@export var windup_time_seconds: float
@export var attack_active_time_seconds: float
@export var recovery_time_seconds: float
@export var next_state: EnemyState

var hitbox_scene: PackedScene = preload("res://prefab/Hitbox.tscn")
var t: float
var phase: Phase

func enter(_msg := {}) -> void:
	enter_phase(Phase.WINDUP)

func update(delta: float) -> void:
	t -= delta
	if t < 0:
		if phase == Phase.WINDUP:
			enter_phase(Phase.ACTIVE)
		elif phase == Phase.ACTIVE:
			enter_phase(Phase.RECOVERY)
		elif phase == Phase.RECOVERY:
			state_machine.transition_to(next_state)
			return

func enter_phase(_phase: Phase):
	phase = _phase
	match phase:
		Phase.WINDUP:
			t = windup_time_seconds
			enemy.sprite.play("attack_windup")
		Phase.ACTIVE:
			t = attack_active_time_seconds
			enemy.sprite.play("attack")
			spawn_hitbox()
		Phase.RECOVERY:
			t = recovery_time_seconds
			enemy.sprite.play("recovery")

func spawn_hitbox():
	var hitbox = hitbox_scene.instantiate()
	enemy.add_child(hitbox)
	var sprite_size = enemy.get_sprite_size()
	var hitbox_offset = Vector2(-50, -sprite_size.y / 3) if enemy.sprite.flip_h else Vector2(50, -sprite_size.y / 3)
	hitbox.init(hitbox_offset, Vector2(64, 64), 0.25, Hitbox.CollideableTypes.Player, 10, enemy, HitEffectRegistry.HIT_EFFECT_1)
