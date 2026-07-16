class_name BossChompLungeState
extends BossState

@export var idle_state: BossIdleState
@export var hitbox_scene: PackedScene

const BOSS_LUNGE_SPEED = 1000
const DASH_DURATION = 3.0
var dash_timer := 0.0
var damping_factor = 1.5
var is_dashing = false
var hitbox: Hitbox = null

var hit: HitConfig = HitConfig.create(20, HitEffectRegistry.HIT_EFFECT_1)

func enter(msg := {}) -> void:
	boss.sprite.play("idle")
	dash_timer = DASH_DURATION
	flash_red(charge_forward)
	
func update(_delta):
	boss.absolute_velocity.x *= exp(-damping_factor * _delta)
	if is_dashing:
		dash_timer -= _delta
		if dash_timer <= 0:
			is_dashing = false
			boss.absolute_velocity.x = 0
			state_machine.transition_to(idle_state)
			boss.sprite.flip_h = !boss.sprite.flip_h
	
func charge_forward():
	is_dashing = true
	boss.sprite.play("chomp")
	boss.absolute_velocity.x = -1000 if !boss.sprite.flip_h else 1000
	if hitbox == null:
		hitbox = hitbox_scene.instantiate()
		boss.add_child(hitbox)
		var sprite_size = boss.get_sprite_size()
		var hitbox_offset = Vector2(0, 0)
		hitbox.init(hitbox_offset, Vector2(450, 335), 1.0, Hitbox.CollideableTypes.Player, boss, hit)
	
func flash_red(cb: Callable):
	boss.absolute_velocity.x = 200 if !boss.sprite.flip_h else -200
	var tween = create_tween()
	tween.tween_property(boss.sprite, "modulate", Color(1, 0, 0), 0.25)
	tween.tween_property(boss.sprite, "modulate", Color(1, 1, 1), 0.25)
	tween.set_loops(5)
	tween.finished.connect(cb)
