class_name IsometryUtils

const Y_AXIS_HIT_RANGE: float = 25
const DEPTH_SCALE: float = 0.5 # Dampens vertical movement by 50%

const SHADOW_MIN_SCALE := 0.45
const SHADOW_HEIGHT_RANGE := 400.0

static func scale_velocity(v: Vector2) -> Vector2:
	# Scale the velocity based on the maximum speed and depth scale
	var scaled_v = v
	scaled_v.y *= DEPTH_SCALE
	return scaled_v

static func scale_shadow_from(z: float) -> float:
	var height_ratio := clampf(absf(z) / SHADOW_HEIGHT_RANGE, 0.0, 1.0)
	return lerpf(1.0, SHADOW_MIN_SCALE, height_ratio)
