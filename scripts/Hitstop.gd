class_name Hitstop

const DEFAULT_DURATION := 0.1

# Node instance id -> resume timestamp (ms). Tracks in-flight freezes so an overlapping hit extends the freeze 
static var _resume_at: Dictionary = {}

static func freeze(nodes: Array, duration: float = DEFAULT_DURATION) -> void:
	for node in nodes:
		_freeze_one(node, duration)

static func _freeze_one(node: Node, duration: float) -> void:
	var id := node.get_instance_id()
	var resume_at := Time.get_ticks_msec() + duration * 1000.0
	if _resume_at.get(id, 0.0) >= resume_at:
		return
	if not _resume_at.has(id):
		node.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	_resume_at[id] = resume_at
	var tree := Engine.get_main_loop() as SceneTree

	var timer = tree.create_timer(duration)
	timer.timeout.connect(_try_resume.bind(node, id, resume_at))

static func _try_resume(node: Node, id: int, scheduled_resume_at: float) -> void:
	if _resume_at.get(id, 0.0) != scheduled_resume_at:
		return

	_resume_at.erase(id)
	if is_instance_valid(node):
		node.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
