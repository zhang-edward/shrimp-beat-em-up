extends Node

var level_configs = []
var curr_wave := 0
var curr_level := 0
var enemies_defeated_for_curr_wave := 0

func _ready():
	var level_resources = ["level1"]
	for res in level_resources:
		var level_config = load("res://resources/levels/" + res + ".tres")
		level_configs.append(level_config)
		
func get_curr_level_config():
	return level_configs[curr_level]
	
func get_curr_wave_config():
	var level_config = get_curr_level_config() as LevelSpawnConfig
	return level_config.wave_configs[curr_wave]

func is_wave_completed():
	var curr_wave_config = get_curr_wave_config() as WaveSpawnConfig
	return curr_wave_config.num_enemies_to_defeat <= enemies_defeated_for_curr_wave

func is_level_completed():
	var level_config = get_curr_level_config() as LevelSpawnConfig
	return curr_wave == level_config.wave_configs.size() - 1
