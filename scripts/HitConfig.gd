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
@export var effect_angle_range_rad: float

static func create(
	damage_: int,
	effect_anim_: SpriteFrames,
	effect_angle_range_rad_: float = TAU,
	knockback_: float = 100.0,
	launch_: float = 0.0,
	knockdown_: bool = false,
	hitstop_: float = Hitstop.DEFAULT_DURATION
) -> HitConfig:
	var hit := HitConfig.new()
	hit.damage = damage_
	hit.effect_anim = effect_anim_
	hit.knockback = knockback_
	hit.launch = launch_
	hit.knockdown = knockdown_
	hit.hitstop = hitstop_
	hit.effect_angle_range_rad = effect_angle_range_rad_
	return hit
