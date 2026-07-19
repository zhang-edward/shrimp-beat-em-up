class_name PiranhaBoss
extends Boss

func _ready():
	boss_name = "Piranha"
	max_health = 300
	game.audio_stream_player.stop()
	game.audio_stream_player.stream = GameVariables.piranha_bgm
	game.audio_stream_player.play()
	
func has_super_armor():
	return super.has_super_armor() or state_machine.state is BossBiteState or state_machine.state is BossChompLungeState

func play_bite_sfx():
	print("playing piranha bite sfx")
	audio_stream_player.stream = GameVariables.piranha_bite_sfx
	audio_stream_player.play()

func play_dash_sfx():
	audio_stream_player.stream = GameVariables.piranha_dash_sfx
	audio_stream_player.play()

func play_windup_sfx():
	audio_stream_player.stream = GameVariables.boss_windup_sfx
	audio_stream_player.play()
