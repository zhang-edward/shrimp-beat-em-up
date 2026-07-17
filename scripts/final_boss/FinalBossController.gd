class_name FinalBossController
extends Node2D

signal animation_sequence_finished()

const STARTING_HEAD_Y = 500
const ELEVATED_HEAD_Y = -200
const WALK_DIP = 40.0

@onready var fg_rest_scale: Vector2 = fg_sprite.scale
@onready var fg_rest_modulate: Color = fg_sprite.modulate

@export var bg_sprite: AnimatedSprite2D
@export var fg_sprite: AnimatedSprite2D
@export var hand1: Node2D
@export var hand2: Node2D
@export var boss_health: BossHealth
@export var player_ref: Player

var tween: Tween
var health = 100

func _ready() -> void:
	# $StateMachine.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	pass

func start_final_boss_fight():
	# $StateMachine.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	boss_health.configure("The Human", 100)
	boss_health.show()

func take_hit(hit: HitConfig, source: Node2D) -> void:
	boss_health.take_damage(hit.damage)
	var dir := Vector2(signf(position.x - source.position.x), 0.0)
	if dir.x == 0.0: # Directly on top of us; shove them the way the attacker faces
		dir.x = -1.0 if source.sprite.flip_h else 1.0

### Animations

func spawn_new_wave_animation(_msg := {}) -> void:
	fg_sprite.visible = false
	_face_appear(bg_sprite)
	await tween.finished

	# See empty tank, worried -> angry
	_play_animation(bg_sprite, "worried")
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	_play_animation(bg_sprite, "angry")
	await tween.finished
	await get_tree().create_timer(1.0).timeout

	# Move to foreground
	_bg_to_fg()
	await tween.finished

	# Reach into tank to place in new enemies
	_play_animation(fg_sprite, "determined_1")
	await tween.finished
	_face_rise(fg_sprite)
	await tween.finished
	_play_animation(fg_sprite, "determined_2")
	await tween.finished
	_play_animation(fg_sprite, "determined_3")
	await tween.finished
	animation_sequence_finished.emit()

func done_spawning_wave_animation(_msg := {}) -> void:
	# Leave tank
	_play_animation(fg_sprite, "determined_1")
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	_face_leave(fg_sprite)
	animation_sequence_finished.emit()

### Animation utils 

func _bg_to_fg(duration = 1.5) -> void:
	fg_sprite.global_position = bg_sprite.global_position
	fg_sprite.global_scale = bg_sprite.global_scale
	fg_sprite.modulate = bg_sprite.modulate
	fg_sprite.animation = bg_sprite.animation
	fg_sprite.frame = bg_sprite.frame

	fg_sprite.visible = true
	bg_sprite.visible = false

	var start_position = fg_sprite.position

	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_method(_walk_to_rest.bind(start_position), 0.0, 1.0, duration)
	tween.parallel().tween_property(fg_sprite, "scale", fg_rest_scale, duration)
	tween.parallel().tween_property(fg_sprite, "modulate", fg_rest_modulate, duration)

# Arc toward rest: parabola is 0 at both ends, dips at the midpoint
func _walk_to_rest(t: float, from: Vector2) -> void:
	var p := from.lerp(Vector2.ZERO, t)
	p.y += WALK_DIP * 4.0 * t * (1.0 - t)
	fg_sprite.position = p

func _face_appear(sprite: AnimatedSprite2D):
	sprite.visible = true
	tween = get_tree().create_tween()
	sprite.position.y = STARTING_HEAD_Y
	sprite.play("default")
	
	# Rise from bottom
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(sprite, "position:y", 0, 1.5)

func _play_animation(sprite: AnimatedSprite2D, anim: String):
	tween = get_tree().create_tween()
	# Emote w/ bounce
	var base_scale = sprite.scale
	tween.tween_callback(func(): sprite.play(anim))
	tween.parallel().tween_property(sprite, "scale", base_scale * (Vector2(1.05, 0.95)), 0.05)
	tween.tween_property(sprite, "scale", base_scale * (Vector2(0.98, 1.02)), 0.05)
	tween.tween_property(sprite, "scale", base_scale, 0.05)

func _face_rise(sprite: AnimatedSprite2D):
	tween = get_tree().create_tween()
	sprite.position.y = 0
	
	# Rise from bottom
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(sprite, "position:y", ELEVATED_HEAD_Y, 0.8)

func _face_leave(sprite: AnimatedSprite2D):
	tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(sprite, "position:y", STARTING_HEAD_Y, 0.8)
