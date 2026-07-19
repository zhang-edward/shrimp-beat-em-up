class_name AudioManager
extends Node

@export var bgm_player: AudioStreamPlayer
@export var sfx_player: AudioStreamPlayer

func play_hit_sfx():
	var hit_sounds = [GameVariables.punch_1, GameVariables.punch_2, GameVariables.punch_3]
	var random_sfx = hit_sounds.pick_random()
	sfx_player.stream = random_sfx
	sfx_player.play()
	
func play_jump_sfx():
	sfx_player.stream = GameVariables.jump_sfx
	sfx_player.play()
	
func play_dash_sfx():
	sfx_player.stream = GameVariables.dash_sfx
	sfx_player.play()
