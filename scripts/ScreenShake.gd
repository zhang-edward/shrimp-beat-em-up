extends Node

## Global screen shake. Registered as an autoload, so call it from anywhere:
##
##   ScreenShake.shake_horizontal(12.0)         # side-to-side, default duration
##   ScreenShake.shake_vertical(8.0, 0.6)       # up-and-down, held longer
##   ScreenShake.shake(Vector2(10.0, 4.0), 0.5) # weighted on both axes
##
## The amplitude decays exponentially over the shake's lifetime, so it kicks hard
## on the first frame and settles quickly. It drives the *active* Camera2D's
## `offset` (found via the viewport), which layers on top of the camera's normal
## follow + position smoothing without fighting it. Nothing else in this project
## writes `offset`, so we own it and zero it out when a shake ends.

# The random offset is re-rolled this many times per second; between rolls it
# lerps toward the new target so the shake reads as a wobble, not per-frame hash.
const FREQUENCY := 24.0

# Larger = faster falloff. At 6.0 the amplitude is a few percent of its peak by
# the tail of a typical short shake.
const DEFAULT_DECAY := 6.0

const DEFAULT_DURATION := 0.4

var _amplitude := Vector2.ZERO   # peak offset in pixels at the start of the shake
var _decay := DEFAULT_DECAY
var _duration := DEFAULT_DURATION
var _falloff_floor := 0.0        # falloff value at _duration, used to normalize
var _elapsed := 0.0
var _from := Vector2.ZERO        # offset we're lerping away from
var _to := Vector2.ZERO          # offset we're lerping toward
var _roll_countdown := 0.0       # seconds until the next re-roll

func _ready() -> void:
	set_process(false)

## Shake left-and-right. `strength` is the peak offset in pixels.
func shake_horizontal(strength: float, duration := DEFAULT_DURATION, decay := DEFAULT_DECAY) -> void:
	shake(Vector2(strength, 0.0), duration, decay)

## Shake up-and-down. `strength` is the peak offset in pixels.
func shake_vertical(strength: float, duration := DEFAULT_DURATION, decay := DEFAULT_DECAY) -> void:
	shake(Vector2(0.0, strength), duration, decay)

## Shake with per-axis peak offsets. Prefer the horizontal/vertical helpers for
## the common cases.
func shake(strength: Vector2, duration := DEFAULT_DURATION, decay := DEFAULT_DECAY) -> void:
	# Don't let a weaker shake cut short a stronger one that's still playing.
	if is_processing() and strength.length() <= _current_peak():
		return
	_amplitude = strength.abs()
	_duration = maxf(duration, 0.001)
	_decay = maxf(decay, 0.001)
	_falloff_floor = exp(-_decay * _duration)
	_elapsed = 0.0
	_from = Vector2.ZERO
	_to = _random_offset()
	_roll_countdown = 1.0 / FREQUENCY
	set_process(true)

## Cancel any in-progress shake and recenter the camera immediately.
func stop() -> void:
	_reset()

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _duration:
		_reset()
		return

	_roll_countdown -= delta
	if _roll_countdown <= 0.0:
		_roll_countdown += 1.0 / FREQUENCY
		_from = _to
		_to = _random_offset()

	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	var blend := 1.0 - clampf(_roll_countdown * FREQUENCY, 0.0, 1.0)
	camera.offset = _from.lerp(_to, blend) * _falloff(_elapsed)

# Exponential falloff normalized to hit exactly 0 at `_duration`, so the shake
# eases out instead of popping when it stops. Stays in [0, 1] for t in [0, dur].
func _falloff(t: float) -> float:
	return (exp(-_decay * t) - _falloff_floor) / (1.0 - _falloff_floor)

func _current_peak() -> float:
	return _amplitude.length() * _falloff(_elapsed)

func _random_offset() -> Vector2:
	return Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _amplitude

func _reset() -> void:
	set_process(false)
	_elapsed = 0.0
	_amplitude = Vector2.ZERO
	var camera := get_viewport().get_camera_2d()
	if camera != null:
		camera.offset = Vector2.ZERO
