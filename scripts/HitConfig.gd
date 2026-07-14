class_name HitConfig
extends Resource

@export var damage: int = 10
# Floor-plane knockback speed, in absolute (pre-IsometryUtils) units
@export var knockback: float = 100.0
# Altitude speed imparted on hit. Negative sends the target up, positive spikes it down.
@export var launch: float = 0.0
# Ragdoll the target instead of putting it in ordinary hitstun
@export var knockdown: bool = false
@export var hitstop: float = Hitstop.DEFAULT_DURATION
@export var effect_anim: SpriteFrames

static func create(
	damage: int,
	effect_anim: SpriteFrames,
	knockback: float = 100.0,
	launch: float = 0.0,
	knockdown: bool = false,
	hitstop: float = Hitstop.DEFAULT_DURATION
) -> HitConfig:
	var hit := HitConfig.new()
	hit.damage = damage
	hit.effect_anim = effect_anim
	hit.knockback = knockback
	hit.launch = launch
	hit.knockdown = knockdown
	hit.hitstop = hitstop
	return hit
