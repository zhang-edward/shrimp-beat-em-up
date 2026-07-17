class_name Hitbox
extends Area2D

enum CollideableTypes {Player, Enemy, Boss}

var _life_timer := 0.5;
# Dictionary used as hash set, with dummy values (true) for each key
var _collision_exceptions := {}
var _collide_with: CollideableTypes = CollideableTypes.Enemy
var _source: Node2D
var _hit: HitConfig

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

func init(pos: Vector2, size: Vector2, lifetime: float, collide_with: CollideableTypes, source: Node2D, hit: HitConfig):
	position = pos
	_collide_with = collide_with
	_collision_shape.shape = RectangleShape2D.new()
	_collision_shape.shape.size = size
	_life_timer = lifetime
	_source = source
	_hit = hit
	area_entered.connect(_handle_area_entered)

func _process(delta):
	_life_timer -= delta
	if _life_timer <= 0:
		queue_free()

func _handle_area_entered(body: Area2D):
	if _collision_exceptions.has(body):
		return
	else:
		_collision_exceptions[body] = true

	if body is Hurtbox:
		var hurtbox = body as Hurtbox
		if hurtbox.parent is Player and _collide_with == CollideableTypes.Player:
			var player = hurtbox.parent as Player
			player.damage(_hit.damage)
			Hitstop.freeze([_source, player], _hit.hitstop)
		var is_hitting_boss = hurtbox.parent is Boss or hurtbox.parent is FinalBossController
		# Attack out of range (not on the same horizontal axis)
		if !is_hitting_boss and (abs(_source.position.y - body.parent.position.y) > IsometryUtils.Y_AXIS_HIT_RANGE):
			return
		elif (hurtbox.parent is Enemy or is_hitting_boss) and _collide_with == CollideableTypes.Enemy:
			var enemy = hurtbox.parent
			enemy.take_hit(_hit, _source)
			spawn_effect(lerp(global_position, enemy.position, 0.5), enemy.position - _source.position)
			Hitstop.freeze([_source, enemy], _hit.hitstop)

func spawn_effect(pos: Vector2, dir: Vector2):
	var config = EffectConfig.new()
	config.pos = pos
	config.anim = _hit.effect_anim
	config.dir = dir
	config.angle_range_rad = _hit.effect_angle_range_rad
	EffectManager.spawn_effect(config)
