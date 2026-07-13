class_name PlayerPunchState
extends PlayerState

const NUDGE_MOVE_SPEED = 50.0
const RECOVERY_TIMES := [0.2, 0.2, 0.4]
const BUFFER_WINDOW := 0.2

@export var move_state: PlayerMoveState

var hitbox_scene: PackedScene = preload("res://prefab/Hitbox.tscn")
var combo_index := 0
var recovery_timer = 0
var comboing: bool

func enter(msg := {}) -> void:
	combo_index = msg["combo_index"] if msg.has("combo_index") else 0
	recovery_timer = RECOVERY_TIMES[combo_index]

	var hitbox = hitbox_scene.instantiate()
	player.add_child(hitbox)
	# var sprite_size = player.get_sprite_size()
	var hitbox_offset = $HitLocation.position
	hitbox_offset.x *= -1 if player.sprite.flip_h else 1
	hitbox.init(hitbox_offset, Vector2(96, 96), 0.25, Hitbox.CollideableTypes.Enemy, 10, player, HitEffectRegistry.HIT_EFFECT_1)

	var anim = "punch_" + str(combo_index)
	player.sprite.play(anim)

	player.scale = Vector2(1.2, 1)
	player.sprite.position.x = -10 if player.sprite.flip_h else 10
	var tween = player.get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(player, "scale", Vector2(1, 1), 0.05)
	tween.tween_property(player.sprite, "position:x", 0, 0.05)

func physics_update(_delta: float) -> void:
	var direction_x = Input.get_axis("move_left", "move_right")
	var direction_y = Input.get_axis("move_up", "move_down")
	player.velocity = Vector2(direction_x * NUDGE_MOVE_SPEED, direction_y * NUDGE_MOVE_SPEED)

func update(delta: float) -> void:
	recovery_timer -= delta

	if recovery_timer <= BUFFER_WINDOW and Input.is_action_just_pressed("attack") and combo_index < 2:
		comboing = true

	if recovery_timer <= 0:
		if comboing:
			state_machine.transition_to(self, {"combo_index": combo_index + 1})
			comboing = false
		else:
			state_machine.transition_to(move_state)
