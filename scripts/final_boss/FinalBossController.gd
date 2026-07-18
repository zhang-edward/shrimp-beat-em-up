class_name FinalBossController
extends Node2D

signal animation_sequence_finished()

enum FacePos {BG, BACK_WALL, BACK_WALL_RISEN, SIDE_LEFT, SIDE_RIGHT}

const BACK_WALL_DOWN_Y = 0.0
const BACK_WALL_RISEN_Y = -400.0
const BACK_WALL_HIDDEN_Y = 800.0
const SIDE_SLIDE_OFFSET = 400.0
const WALK_DIP = 40.0

@onready var fg_rest_scale: Vector2 = fg_sprite.scale
@onready var fg_rest_modulate: Color = fg_sprite.modulate
@onready var fg_sprite_l: AnimatedSprite2D = $ManSpriteL
@onready var fg_sprite_r: AnimatedSprite2D = $ManSpriteR
@onready var left_sprite_resting_pos := fg_sprite_l.position.x
@onready var right_sprite_resting_pos := fg_sprite_r.position.x

@export var bg_sprite: AnimatedSprite2D
@export var fg_sprite: AnimatedSprite2D
@export var hand1: Node2D
@export var hand2: Node2D
@export var boss_health: BossHealth
@export var player_ref: Player

var _face_pos: FacePos = FacePos.BG
var _tween: Tween
var health = 100

func start_final_boss_fight():
	boss_health.configure("The Human", 100)
	boss_health.show()

func take_hit(hit: HitConfig, source: Node2D) -> void:
	boss_health.take_damage(hit.damage)
	var dir := Vector2(signf(position.x - source.position.x), 0.0)
	if dir.x == 0.0:
		dir.x = -1.0 if source.sprite.flip_h else 1.0

### Face positioning

# Move the boss to any position, playing whatever transition gets there from where it is now
func move_face_to(target: FacePos, emote: String) -> void:
	if target == _face_pos:
		return
	if _tween and _tween.is_valid():
		_tween.kill()

	var from := _face_pos
	if _is_back_wall(from) and _is_back_wall(target):
		await _shift_back_wall(target)
	else:
		await _exit(from)
		await _enter(target, from, emote)
	_face_pos = target

func active_sprite() -> AnimatedSprite2D:
	match _face_pos:
		FacePos.BG: return bg_sprite
		FacePos.SIDE_LEFT: return fg_sprite_l
		FacePos.SIDE_RIGHT: return fg_sprite_r
		_: return fg_sprite

func play_emote(anim: String) -> void:
	var sprite := active_sprite()
	var base := sprite.scale
	var t := get_tree().create_tween()
	t.tween_callback(func(): sprite.play(anim))
	t.parallel().tween_property(sprite, "scale", base * Vector2(1.05, 0.95), 0.05)
	t.tween_property(sprite, "scale", base * Vector2(0.98, 1.02), 0.05)
	t.tween_property(sprite, "scale", base, 0.05)
	await t.finished

func track_face_x(pos_x: float) -> void:
	var t := get_tree().create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(fg_sprite, "position:x", pos_x, 0.3)

func face_impact_bounce() -> void:
	fg_sprite.position.y = BACK_WALL_RISEN_Y - 50
	var t := get_tree().create_tween()
	t.set_ease(Tween.EASE_IN)
	t.tween_property(fg_sprite, "position:y", BACK_WALL_RISEN_Y, 0.8)

### Transitions

func _is_back_wall(pos: FacePos) -> bool:
	return pos == FacePos.BACK_WALL or pos == FacePos.BACK_WALL_RISEN

func _enter(target: FacePos, from: FacePos, emote: String) -> void:
	match target:
		FacePos.BG:
			bg_sprite.visible = true
		FacePos.BACK_WALL:
			await _face_to_back_wall(from, emote)
		FacePos.BACK_WALL_RISEN:
			await _face_to_back_wall(from, emote)
			await _shift_back_wall(FacePos.BACK_WALL_RISEN)
		FacePos.SIDE_LEFT:
			await _slide_side_in(fg_sprite_l, left_sprite_resting_pos, -SIDE_SLIDE_OFFSET)
		FacePos.SIDE_RIGHT:
			await _slide_side_in(fg_sprite_r, right_sprite_resting_pos, SIDE_SLIDE_OFFSET)

func _exit(current: FacePos) -> void:
	match current:
		FacePos.BG:
			bg_sprite.visible = false
		FacePos.BACK_WALL, FacePos.BACK_WALL_RISEN:
			await _drop_below_rim()
		FacePos.SIDE_LEFT:
			await _slide_side_out(fg_sprite_l, left_sprite_resting_pos - SIDE_SLIDE_OFFSET)
		FacePos.SIDE_RIGHT:
			await _slide_side_out(fg_sprite_r, right_sprite_resting_pos + SIDE_SLIDE_OFFSET)

func _face_to_back_wall(from: FacePos, emote: String) -> void:
	if from == FacePos.BG:
		await _walk_from_bg(emote)
	else:
		await _rise_from_rim(emote)

func _rise_from_rim(emote: String) -> void:
	fg_sprite.visible = true
	fg_sprite.position = Vector2(0, BACK_WALL_HIDDEN_Y)
	fg_sprite.play(emote)
	_tween = _ease_tween()
	_tween.tween_property(fg_sprite, "position:y", BACK_WALL_DOWN_Y, 1.5)
	await _tween.finished

func _shift_back_wall(target: FacePos) -> void:
	var y := BACK_WALL_RISEN_Y if target == FacePos.BACK_WALL_RISEN else BACK_WALL_DOWN_Y
	_tween = _ease_tween()
	_tween.tween_property(fg_sprite, "position:y", y, 0.8)
	await _tween.finished

func _drop_below_rim() -> void:
	_tween = _ease_tween()
	_tween.tween_property(fg_sprite, "position:y", BACK_WALL_HIDDEN_Y, 0.8)
	await _tween.finished
	fg_sprite.visible = false

func _slide_side_in(sprite: AnimatedSprite2D, rest_x: float, offset: float) -> void:
	sprite.visible = true
	sprite.play("default")
	sprite.position.x = rest_x + offset
	_tween = get_tree().create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(sprite, "position:x", rest_x, 0.5)
	await _tween.finished

func _slide_side_out(sprite: AnimatedSprite2D, off_x: float) -> void:
	_tween = get_tree().create_tween()
	_tween.tween_property(sprite, "position:x", off_x, 0.5)
	await _tween.finished
	sprite.visible = false

# Hand the dim background guy's pose to the foreground sprite and walk him toward the tank
func _walk_from_bg(emote: String, duration := 1.5) -> void:
	fg_sprite.play(emote)
	bg_sprite.play(emote)
	fg_sprite.global_position = bg_sprite.global_position
	fg_sprite.global_scale = bg_sprite.global_scale
	fg_sprite.modulate = bg_sprite.modulate
	fg_sprite.animation = bg_sprite.animation
	fg_sprite.frame = bg_sprite.frame
	fg_sprite.visible = true
	bg_sprite.visible = false

	var start := fg_sprite.position
	_tween = _ease_tween()
	_tween.tween_method(_walk_arc.bind(start), 0.0, 1.0, duration)
	_tween.parallel().tween_property(fg_sprite, "scale", fg_rest_scale, duration)
	_tween.parallel().tween_property(fg_sprite, "modulate", fg_rest_modulate, duration)
	await _tween.finished

# Parabola that dips WALK_DIP at the midpoint and is zero at both ends
func _walk_arc(t: float, from: Vector2) -> void:
	var p := from.lerp(Vector2.ZERO, t)
	p.y += WALK_DIP * 4.0 * t * (1.0 - t)
	fg_sprite.position = p

func _ease_tween() -> Tween:
	var t := get_tree().create_tween()
	t.set_ease(Tween.EASE_IN_OUT)
	t.set_trans(Tween.TRANS_QUAD)
	return t

### Scripted sequences

func spawn_new_wave_animation(_msg := {}) -> void:
	await move_face_to(FacePos.BG, "default")
	await play_emote("worried")
	await get_tree().create_timer(1.0).timeout
	await play_emote("angry")
	await get_tree().create_timer(1.0).timeout
	await move_face_to(FacePos.BACK_WALL, "angry")
	await play_emote("determined_1")
	await move_face_to(FacePos.BACK_WALL_RISEN, "determined_1")
	await play_emote("determined_2")
	await play_emote("determined_3")
	animation_sequence_finished.emit()

func done_spawning_wave_animation(_msg := {}) -> void:
	await play_emote("determined_1")
	await get_tree().create_timer(1.0).timeout
	await move_face_to(FacePos.BG, "determined_1")
	animation_sequence_finished.emit()
