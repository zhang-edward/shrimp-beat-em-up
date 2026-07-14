class_name IsometryUtils

const Y_AXIS_HIT_RANGE: float = 25
const DEPTH_SCALE: float = 0.5 # Dampens vertical movement by 50%

static func scale_velocity(v: Vector2) -> Vector2:
	# Scale the velocity based on the maximum speed and depth scale
	var scaled_v = v
	scaled_v.y *= DEPTH_SCALE
	return scaled_v