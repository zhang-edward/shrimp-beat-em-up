class_name Hitbox
extends Area2D

enum CollideableTypes {Player, Enemy}

var _life_timer := 0.5;
# Dictionary used as hash set, with dummy values (true) for each key
var _collision_exceptions := {}
var _collide_with: CollideableTypes = CollideableTypes.Enemy
var _damage: int

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

func init(pos: Vector2, size: Vector2, lifetime: float, collide_with: CollideableTypes, damage: int):
	position = pos
	_collide_with = collide_with
	_collision_shape.shape = RectangleShape2D.new()
	_collision_shape.shape.size = size
	_life_timer = lifetime
	_damage = damage
	body_entered.connect(_handle_body_entered)

func _process(delta):
	_life_timer -= delta
	if _life_timer <= 0:
		queue_free()

func _handle_body_entered(body: Node2D):
	if _collision_exceptions.has(body):
		return
	else:
		_collision_exceptions[body] = true

	if _collide_with == CollideableTypes.Player and body is Player:
		var player = body as Player
		player.damage(_damage)
	if _collide_with == CollideableTypes.Enemy and body is Enemy:
		var enemy = body as Enemy
		enemy.damage(_damage)
