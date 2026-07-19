class_name DebugMenu
extends CanvasLayer

const TOGGLE_KEYS := [KEY_F1, KEY_QUOTELEFT]

var _game: Game
var _panel: PanelContainer
var _list: VBoxContainer

func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	layer = 128 # draw on top of everything
	_game = get_node_or_null("/root/Game") as Game
	_build_ui()
	_panel.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode in TOGGLE_KEYS:
		_toggle()
		get_viewport().set_input_as_handled()

func _toggle() -> void:
	if _panel.visible:
		_panel.hide()
	else:
		_rebuild()
		_panel.show()

func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_panel.position = Vector2(20, 20)
	add_child(_panel)

	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "DEBUG — skip to level / wave   (F1 or ` to close)"
	vbox.add_child(title)

	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 4)
	vbox.add_child(_list)

# Rebuilt each time the menu opens so it always reflects the loaded configs.
func _rebuild() -> void:
	for child in _list.get_children():
		child.queue_free()
	if _game == null:
		_game = get_node_or_null("/root/Game") as Game

	for level_idx in range(GameVariables.level_configs.size()):
		var level_config := GameVariables.level_configs[level_idx] as LevelSpawnConfig

		var header := Label.new()
		header.text = "Level %d" % (level_idx + 1)
		_list.add_child(header)

		for wave_idx in range(level_config.wave_configs.size()):
			var wave_btn := Button.new()
			wave_btn.text = "    Wave %d" % (wave_idx + 1)
			wave_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			wave_btn.pressed.connect(_on_wave_pressed.bind(level_idx, wave_idx))
			_list.add_child(wave_btn)

		if level_config.boss_scene != null:
			var boss_btn := Button.new()
			boss_btn.text = "    Boss"
			boss_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			boss_btn.pressed.connect(_on_boss_pressed.bind(level_idx))
			_list.add_child(boss_btn)

	var final_boss_btn := Button.new()
	final_boss_btn.text = "Final Boss"
	final_boss_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	final_boss_btn.pressed.connect(_on_final_boss_pressed)
	_list.add_child(final_boss_btn)

func _on_wave_pressed(level_idx: int, wave_idx: int) -> void:
	_panel.hide()
	if _game != null:
		_game.debug_jump_to_wave(level_idx, wave_idx)

func _on_boss_pressed(level_idx: int) -> void:
	_panel.hide()
	if _game != null:
		_game.debug_jump_to_boss(level_idx)

func _on_final_boss_pressed() -> void:
	_panel.hide()
	if _game != null:
		_game.debug_jump_to_final_boss()
