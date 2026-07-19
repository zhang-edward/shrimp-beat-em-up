extends Node

enum GameOverState {
	DEFEAT,
	VICTORY
}

var level_configs = []
var curr_wave := 0
var curr_level := 0
var enemies_defeated_for_curr_wave := 0
var game_over_state: GameOverState

var game_bgm: AudioStream
var piranha_bgm: AudioStream
var lobster_bgm: AudioStream
var final_boss_bgm: AudioStream

var hurt_1: AudioStream
var hurt_2: AudioStream
var hurt_3: AudioStream
var jump_sfx: AudioStream
var dash_sfx: AudioStream
var attack_sfx: AudioStream
var enemy_attack_sfx: AudioStream
var player_hurt_sfx: AudioStream
var respawn_sfx: AudioStream
var death_sfx: AudioStream

func _ready():
	var level_resources = ["level2"]
	for res in level_resources:
		var level_config = load("res://resources/levels/" + res + ".tres")
		level_configs.append(level_config)
	# Background music
	game_bgm = load("res://audio/music/main_level.ogg")
	piranha_bgm = load("res://audio/music/piranha_boss.ogg")
	lobster_bgm = load("res://audio/music/lobster_boss.ogg")
	final_boss_bgm = load("res://audio/music/final_boss.ogg")
	# Sound effects
	hurt_1 = load("res://audio/sfx/hurt1.wav")
	hurt_2 = load("res://audio/sfx/hurt2.wav")
	hurt_3 = load("res://audio/sfx/hurt3.wav")
	jump_sfx = load("res://audio/sfx/jump.wav")
	dash_sfx = load("res://audio/sfx/dash.wav")
	attack_sfx = load("res://audio/sfx/whoosh.wav")
	enemy_attack_sfx = load("res://audio/sfx/enemy_attack.wav")
	player_hurt_sfx = load("res://audio/sfx/player_hurt.wav")
	respawn_sfx = load("res://audio/sfx/respawn.wav")
	death_sfx = load("res://audio/sfx/death.wav")
	
func get_curr_level_config():
	return level_configs[curr_level]
	
func get_curr_wave_config():
	var level_config = get_curr_level_config() as LevelSpawnConfig
	return level_config.wave_configs[curr_wave]

func is_wave_completed():
	var curr_wave_config = get_curr_wave_config() as WaveSpawnConfig
	return curr_wave_config.total_enemy_count() <= enemies_defeated_for_curr_wave

func is_level_completed():
	var level_config = get_curr_level_config() as LevelSpawnConfig
	return curr_wave == level_config.wave_configs.size() - 1
