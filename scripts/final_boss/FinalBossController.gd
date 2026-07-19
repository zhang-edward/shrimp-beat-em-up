class_name FinalBossController
extends Node2D

signal animation_sequence_finished()
# Emitted once the death sequence has finished playing out, so the game can move
# on to the victory screen.
signal defeated()

enum FacePos {BG, BACK_WALL, BACK_WALL_RISEN, SIDE_LEFT, SIDE_RIGHT, ABSENT}

const BACK_WALL_DOWN_Y = 0.0
const BACK_WALL_RISEN_Y = -400.0
const BACK_WALL_HIDDEN_Y = 800.0
const BG_WALL_HIDDEN_Y = 500.0
const SIDE_SLIDE_OFFSET = 400.0
const WALK_DIP = 40.0
const LEFT_SPRITE_RESTING_POS := -825
const RIGHT_SPRITE_RESTING_POS := 825

@onready var fg_rest_scale: Vector2 = fg_sprite.scale
@onready var fg_rest_modulate: Color = fg_sprite.modulate
@onready var fg_sprite_l: AnimatedSprite2D = $ManSpriteL
@onready var fg_sprite_r: AnimatedSprite2D = $ManSpriteR
@onready var state_machine: StateMachine = $StateMachine
@onready var game = get_node("/root/Game") as Game

@export var bg_sprite: AnimatedSprite2D
@export var fg_sprite: AnimatedSprite2D
@export var hand1: Node2D
@export var hand2: Node2D
@export var boss_health: BossHealth
@export var player_ref: Player
# The attack state the fight opens on. The state machine idles in
# FinalBossInactiveState until start_final_boss_fight() hands control to this.
@export var first_fight_state: FinalBossState

var _face_pos: FacePos = FacePos.ABSENT
var _tween: Tween
var health = 100
var _defeated := false

func start_final_boss_fight():
	await final_boss_start_sequence()

func take_hit(hit: HitConfig, source: Node2D) -> void:
	if _defeated:
		return
	boss_health.take_damage(hit.damage)
	if boss_health.get_health() <= 0:
		_defeated = true
		_play_death_sequence()
		return
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
	if target == FacePos.ABSENT:
		await _exit(from)
	elif _is_back_wall(from) and _is_back_wall(target):
		await _shift_back_wall(target)
	else:
		if !(from == FacePos.BG and target == FacePos.BACK_WALL):
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
			await _rise_to_bg(emote)
		FacePos.BACK_WALL:
			await _face_to_back_wall(from, emote)
		FacePos.BACK_WALL_RISEN:
			await _face_to_back_wall(from, emote)
			await _shift_back_wall(FacePos.BACK_WALL_RISEN)
		FacePos.SIDE_LEFT:
			await _slide_side_in(fg_sprite_l, LEFT_SPRITE_RESTING_POS, -SIDE_SLIDE_OFFSET)
		FacePos.SIDE_RIGHT:
			await _slide_side_in(fg_sprite_r, RIGHT_SPRITE_RESTING_POS, SIDE_SLIDE_OFFSET)

func _exit(current: FacePos) -> void:
	match current:
		FacePos.BG:
			await _drop_below_rim_bg()
		FacePos.BACK_WALL, FacePos.BACK_WALL_RISEN:
			await _drop_below_rim()
		FacePos.SIDE_LEFT:
			await _slide_side_out(fg_sprite_l, LEFT_SPRITE_RESTING_POS - SIDE_SLIDE_OFFSET)
		FacePos.SIDE_RIGHT:
			await _slide_side_out(fg_sprite_r, RIGHT_SPRITE_RESTING_POS + SIDE_SLIDE_OFFSET)
		FacePos.ABSENT:
			pass

func _rise_to_bg(emote: String) -> void:
	bg_sprite.visible = true
	bg_sprite.position = Vector2(0, BG_WALL_HIDDEN_Y)
	bg_sprite.play(emote)
	_tween = _ease_tween()
	_tween.tween_property(bg_sprite, "position:y", 0, 1.5)
	await _tween.finished

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

func _drop_below_rim_bg() -> void:
	_tween = _ease_tween()
	_tween.tween_property(bg_sprite, "position:y", 500, 0.8)
	await _tween.finished
	bg_sprite.visible = false

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

# Stage 1: mild concern. put replace fish in tank
# Stage 2: angry. put spiky snails in tank
# Stage 3: angry and evil pose. put crabs in tank
func spawn_new_wave_animation(stage: int) -> void:
	await move_face_to(FacePos.BG, "default")
	await play_emote("worried")
	await get_tree().create_timer(1.0).timeout
	if stage == 2:
		await play_emote("angry")
		await get_tree().create_timer(1.0).timeout
	await move_face_to(FacePos.BACK_WALL, "worried" if stage == 1 else "angry")
	if stage == 3:
		await play_emote("determined_1")
	await move_face_to(FacePos.BACK_WALL_RISEN, "determined_1" if stage == 3 else "angry")
	await play_emote("determined_3")
	animation_sequence_finished.emit()

func done_spawning_wave_animation(_msg := {}) -> void:
	await play_emote("default")
	await get_tree().create_timer(1.0).timeout
	await move_face_to(FacePos.ABSENT, "")
	animation_sequence_finished.emit()

#### Final Boss

func final_boss_start_sequence() -> void:
	await move_face_to(FacePos.BG, "default")
	await play_emote("worried")
	await get_tree().create_timer(1.0).timeout
	await move_face_to(FacePos.BACK_WALL, "worried")
	await get_tree().create_timer(2.0).timeout
	await play_emote("solemn")
	await get_tree().create_timer(4.0).timeout
	await play_emote("super_angry")
	game.audio_stream_player.volume_db = 0.0
	game.audio_stream_player.stream = GameVariables.final_boss_bgm
	game.audio_stream_player.play()
	await get_tree().create_timer(2.0).timeout
	boss_health.configure("The Human", 100)
	boss_health.show()
	await move_face_to(FacePos.BACK_WALL_RISEN, "super_angry")
	await play_emote("determined_3")
	state_machine.transition_to(first_fight_state)

#### Death

func _play_death_sequence() -> void:
	# Halt the AI so nothing keeps punching/grabbing while he dies.
	state_machine.stop()
	_retract_hands()
	# Come to rest at the back wall, centered, so the death reads clearly.
	await move_face_to(FacePos.BACK_WALL, "angry")
	var settle := get_tree().create_tween()
	settle.set_ease(Tween.EASE_OUT)
	settle.tween_property(fg_sprite, "position:x", 0.0, 0.3)
	await settle.finished
	await get_tree().create_timer(3.0).timeout
	await play_emote("death")
	await get_tree().create_timer(0.6).timeout
	await _keel_over()
	defeated.emit()

# Topple the face over: rotate it down toward the ground while it sinks below the
# rim, as if the body has gone limp and fallen.
func _keel_over() -> void:
	var t := get_tree().create_tween()
	t.set_ease(Tween.EASE_IN)
	t.set_trans(Tween.TRANS_QUAD)
	t.tween_property(fg_sprite, "rotation", deg_to_rad(90.0), 1.2)
	t.parallel().tween_property(fg_sprite, "position:y", BACK_WALL_HIDDEN_Y, 1.4)
	await t.finished

# Pull both fists back up out of the tank so they don't hang mid-air after death.
func _retract_hands() -> void:
	for hand in [hand1, hand2]:
		var sprite := hand.get_node("Sprite") as AnimatedSprite2D
		sprite.show()
		hand.get_node("Shadow").show()
		var t := get_tree().create_tween()
		t.set_ease(Tween.EASE_IN)
		t.set_trans(Tween.TRANS_QUAD)
		t.tween_property(sprite, "position:y", -800.0, 0.4)
