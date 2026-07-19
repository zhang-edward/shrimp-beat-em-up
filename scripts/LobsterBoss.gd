class_name LobsterBoss
extends Boss

@export var claw_destroy_state: BossClawDestroyState

@onready var left_claw: LobsterBossClaw = $AnimatedSprite2D/LeftClaw as LobsterBossClaw
@onready var right_claw: LobsterBossClaw = $AnimatedSprite2D/RightClaw as LobsterBossClaw
@onready var left_claw_health: BossHealth = $CanvasLayer/HBoxContainer/LeftClawHealth as BossHealth
@onready var right_claw_health: BossHealth = $CanvasLayer/HBoxContainer/RightClawHealth as BossHealth

func _ready():
	game.audio_stream_player.stop()
	game.audio_stream_player.stream = GameVariables.lobster_bgm
	game.audio_stream_player.play()
	boss_name = "Lobster"
	left_claw.health = left_claw_health
	left_claw.lobster_boss = self
	right_claw.health = right_claw_health
	right_claw.lobster_boss = self
	
func has_super_armor():
	return super.has_super_armor() or state_machine.state is BossSnapState or state_machine.state is BossSlamState

func take_hit(hit: HitConfig, source: Node2D) -> void:
	pass

func setup():
	game.player.top_level = true
	left_claw_health.configure("Left claw", 200)
	right_claw_health.configure("Right claw", 200)

func handle_hit():
	if state_machine.state is LobsterBossIdleState:
		state_machine.transition_to(hurt_state)

func handle_claw_destroy(claw: LobsterBossClaw):
	state_machine.transition_to(claw_destroy_state, {"claw_destroyed": claw})

func die():
	super.die()
	
func reset_anims():
	sprite.play("idle")
	left_claw.sprite.play("idle")
	right_claw.sprite.play("idle")

func play_snap_sfx():
	audio_stream_player.stream = GameVariables.lobster_snap_sfx
	audio_stream_player.play()
	
func play_windup_sfx():
	audio_stream_player.stream = GameVariables.boss_windup_sfx
	audio_stream_player.play()
	
func play_slam_sfx():
	audio_stream_player.stream = GameVariables.lobster_slam_sfx
	audio_stream_player.play()
