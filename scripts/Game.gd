class_name Game
extends Node2D

@onready var enemy_spawner = %EnemySpawner as EnemySpawner
@onready var wave_stats_label = $CanvasLayer/WaveStats as Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_next_wave()
	update_wave_stats()
	
func update_wave_stats():
	var curr_wave_config = GameVariables.get_curr_wave_config() as WaveSpawnConfig
	wave_stats_label.text = "Wave " + str(GameVariables.curr_wave + 1) + ": " + str(GameVariables.enemies_defeated_for_curr_wave) + " / " + str(curr_wave_config.num_enemies_to_defeat)

func incr_enemy_defeated_count():
	GameVariables.enemies_defeated_for_curr_wave += 1
	if GameVariables.is_wave_completed():
		if GameVariables.is_level_completed():
			if GameVariables.curr_level == GameVariables.level_configs.size() - 1:
				get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
			else:
				GameVariables.curr_level += 1
				load_next_level()
		else:
			GameVariables.curr_wave += 1
			load_next_wave()
	update_wave_stats()
		
func load_next_wave():
	var curr_wave_config = GameVariables.get_curr_wave_config()
	enemy_spawner.clear_curr_enemies()
	GameVariables.enemies_defeated_for_curr_wave = 0
	enemy_spawner.load_wave_config(curr_wave_config)
	enemy_spawner.start()
	
func load_next_level():
	GameVariables.curr_wave = 0
	load_next_wave()
