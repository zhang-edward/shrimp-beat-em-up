class_name BossBiteState
extends BossState

@export var idle_state: BossIdleState
@export var hitbox_scene: PackedScene
var hit: HitConfig = HitConfig.create(25, HitEffectRegistry.HIT_EFFECT_1)
var hitbox: Hitbox

func enter(msg := {}):
	boss.velocity = Vector2.ZERO
	boss.sprite.play("bite")
	boss.sprite.animation_finished.connect(on_anim_completed, CONNECT_ONE_SHOT)
	
func update(_delta) -> void:
	if boss.sprite.frame == 4 and hitbox == null:
		hitbox = hitbox_scene.instantiate()
		boss.add_child(hitbox)
		var hitbox_offset = Vector2(-50 if !boss.sprite.flip_h else 50, -150)
		hitbox.init(hitbox_offset, Vector2(550, 335), 0.25, Hitbox.CollideableTypes.Player, boss, hit)
		
func exit():
	hitbox = null
	
func on_anim_completed():
	state_machine.transition_to(idle_state, {})
