class_name Game
extends Node2D

@onready var enemy_spawner = %EnemySpawner as EnemySpawner
@onready var boss_health = $CanvasLayer/BossHealth as BossHealth
@export var enemies_folder: Node
@onready var wave_stats_label = $CanvasLayer/WaveStats as Label

var BOSS_SPAWN_LOCATION: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_wave_stats()
	var screen_size = get_viewport().size	
	BOSS_SPAWN_LOCATION = Vector2(screen_size.x / 2 - 100, -screen_size.y / 2 - 100)
	load_level_boss()
	
func update_wave_stats():
	var curr_wave_config = GameVariables.get_curr_wave_config() as WaveSpawnConfig
	wave_stats_label.text = "Wave " + str(GameVariables.curr_wave + 1) + ": " + str(GameVariables.enemies_defeated_for_curr_wave) + " / " + str(curr_wave_config.num_enemies_to_defeat)

func incr_enemy_defeated_count():
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
	var boss = level_config.boss_scene.instantiate() as Boss
	enemies_folder.add_child(boss)
	boss_health.configure_from_boss(boss)
	boss_health.show()
	boss.global_position = BOSS_SPAWN_LOCATION
		
func load_next_wave():
	var curr_wave_config = GameVariables.get_curr_wave_config()
	enemy_spawner.clear_curr_enemies()
	GameVariables.enemies_defeated_for_curr_wave = 0
	enemy_spawner.load_wave_config(curr_wave_config)
	enemy_spawner.start()
	
func load_next_level():
	GameVariables.curr_wave = 0
	load_next_wave()
