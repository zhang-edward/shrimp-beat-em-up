class_name Game
extends Node2D

@onready var enemy_spawner = %EnemySpawner as EnemySpawner
@onready var wave_stats_label = $CanvasLayer/WaveStats as Label
@onready var canvas_layer = $CanvasLayer as CanvasLayer
@onready var player = $Entities/Player as Player

@export var enemies_folder: Node
@export var audio_stream_player: AudioStreamPlayer
@export var sfx_player: AudioStreamPlayer
@export var final_boss_controller: FinalBossController

var BOSS_SPAWN_LOCATION: Vector2
var boss
var is_tutorial := true
var tutorial_fish_killed = 0 # total of 3 tutorial fish

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_stream_player.stream = GameVariables.game_bgm
	audio_stream_player.play()
	update_wave_stats()
	var screen_size = get_viewport().size
	BOSS_SPAWN_LOCATION = Vector2(screen_size.x / 2 - 512, -screen_size.y / 2 - 100)
	final_boss_controller.defeated.connect(handle_final_boss_defeated)

	var tutorial = %Tutorial
	var tween = get_tree().create_tween()
	tween.tween_callback(func(): tutorial.modulate = Color.GRAY)
	tween.tween_interval(0.5)
	tween.tween_callback(func(): tutorial.modulate = Color.WHITE)
	tween.tween_interval(0.5)
	tween.set_loops()

func update_wave_stats():
	var curr_wave_config = GameVariables.get_curr_wave_config() as WaveSpawnConfig
	wave_stats_label.text = "Wave " + str(GameVariables.curr_wave + 1) + ": " + str(GameVariables.enemies_defeated_for_curr_wave) + " / " + str(curr_wave_config.total_enemy_count())

func incr_enemy_defeated_count():
	# Fighting final boss -> don't load any more levels / waves
	if final_boss_controller.state_machine.state is not FinalBossInactiveState:
		return

	if is_tutorial:
		tutorial_fish_killed += 1
		if tutorial_fish_killed >= 3:
			load_next_wave()
			is_tutorial = false
			%Tutorial.visible = false
		return

	GameVariables.enemies_defeated_for_curr_wave += 1
	if GameVariables.is_wave_completed():
		if GameVariables.is_level_completed():
			load_level_boss()
		else:
			GameVariables.curr_wave += 1
			load_next_wave()
	update_wave_stats()
	
func load_level_boss():
	var level_config = GameVariables.get_curr_level_config()
	if level_config.boss_scene != null:
		boss = level_config.boss_scene.instantiate() as Boss
		boss.global_position = BOSS_SPAWN_LOCATION
		enemies_folder.add_child(boss)
		boss.setup()
	else:
		if GameVariables.curr_level == GameVariables.level_configs.size() - 1:
			get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
		else:
			GameVariables.curr_level += 1
			load_next_level()
			update_wave_stats()

func start_final_boss_fight():
	final_boss_controller.start_final_boss_fight()

func load_next_wave():
	var boss_animation_variation = 1
	if GameVariables.curr_level == 1:
		boss_animation_variation = 2
	elif GameVariables.curr_level >= 2:
		boss_animation_variation = 3
	final_boss_controller.spawn_new_wave_animation(boss_animation_variation)
	await final_boss_controller.animation_sequence_finished
	var curr_wave_config = GameVariables.get_curr_wave_config()
	enemy_spawner.clear_curr_enemies()
	GameVariables.enemies_defeated_for_curr_wave = 0
	enemy_spawner.load_wave_config(curr_wave_config)
	enemy_spawner.start()
	
	await get_tree().create_timer(1.0).timeout
	final_boss_controller.done_spawning_wave_animation()

func load_next_level():
	GameVariables.curr_wave = 0
	load_next_wave()

### Debug: skip straight to a level/wave or a level's boss (see DebugMenu.gd)

func debug_jump_to_wave(level: int, wave: int) -> void:
	is_tutorial = false;
	_debug_clear_combatants()
	GameVariables.curr_level = level
	GameVariables.curr_wave = wave
	GameVariables.enemies_defeated_for_curr_wave = 0
	load_next_wave()
	update_wave_stats()

func debug_jump_to_boss(level: int) -> void:
	is_tutorial = false;
	_debug_clear_combatants()
	var level_config := GameVariables.level_configs[level] as LevelSpawnConfig
	GameVariables.curr_level = level
	GameVariables.curr_wave = max(level_config.wave_configs.size() - 1, 0)
	GameVariables.enemies_defeated_for_curr_wave = 0
	load_level_boss()
	update_wave_stats()

func debug_jump_to_final_boss() -> void:
	is_tutorial = false;
	_debug_clear_combatants()
	GameVariables.curr_level = GameVariables.level_configs.size() - 1
	start_final_boss_fight()

func _debug_clear_combatants() -> void:
	enemy_spawner.clear_all_enemies()
	if boss != null and is_instance_valid(boss):
		boss.queue_free()
	boss = null

# The final boss plays its own death sequence and then emits `defeated`; once it
# does, the game is won.
func handle_final_boss_defeated():
	GameVariables.game_over_state = GameVariables.GameOverState.VICTORY
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func handle_boss_defeated():
	# The health bar is reparented onto the game's canvas layer in Boss.setup(), so
	# it outlives the boss node; free it explicitly or it lingers on screen.
	if is_instance_valid(boss.boss_health):
		boss.boss_health.queue_free()
	boss.queue_free()
	boss = null
	if GameVariables.curr_level == GameVariables.level_configs.size() - 1:
		var tween = create_tween()
		tween.tween_property(audio_stream_player, "volume_db", -50.0, 1.5)
		start_final_boss_fight()
	else:
		audio_stream_player.stop()
		audio_stream_player.stream = GameVariables.game_bgm
		audio_stream_player.play()
		GameVariables.curr_level += 1
		load_next_level()
		update_wave_stats()
