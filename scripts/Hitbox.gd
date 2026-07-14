class_name Hitbox
extends Area2D

enum CollideableTypes {Player, Enemy}

var _life_timer := 0.5;
# Dictionary used as hash set, with dummy values (true) for each key
var _collision_exceptions := {}
var _collide_with: CollideableTypes = CollideableTypes.Enemy
var _damage: int
var _source: Node2D
var _effect_anim: SpriteFrames

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

func init(pos: Vector2, size: Vector2, lifetime: float, collide_with: CollideableTypes, damage: int, source: Node2D, effect_anim: SpriteFrames = null):
	position = pos
	_collide_with = collide_with
	_collision_shape.shape = RectangleShape2D.new()
	_collision_shape.shape.size = size
	_life_timer = lifetime
	_damage = damage
	_source = source
	_effect_anim = effect_anim
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
		# Attack out of range (not on the same horizontal axis)
		if _source.position.y - body.parent.position.y > IsometryUtils.Y_AXIS_HIT_RANGE:
			print("out of range! misalignment: ", _source.position.y - body.parent.position.y)
			return
		if hurtbox.parent is Player and _collide_with == CollideableTypes.Player:
			var player = hurtbox.parent as Player
			player.damage(_damage)
			Hitstop.freeze([_source, player])
		elif hurtbox.parent is Enemy and _collide_with == CollideableTypes.Enemy:
			var enemy = hurtbox.parent as Enemy
			enemy.damage(_damage, _source)
			spawn_effect(lerp(global_position, enemy.position, 0.5))
			Hitstop.freeze([_source, enemy])

func spawn_effect(pos: Vector2):
	var config = EffectConfig.new()
	config.pos = pos
	config.anim = _effect_anim
	EffectManager.spawn_effect(config)
