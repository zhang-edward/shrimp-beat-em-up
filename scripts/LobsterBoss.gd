class_name LobsterBoss
extends Boss

@export var claw_destroy_state: BossClawDestroyState

@onready var left_claw: LobsterBossClaw = $AnimatedSprite2D/LeftClaw as LobsterBossClaw
@onready var right_claw: LobsterBossClaw = $AnimatedSprite2D/RightClaw as LobsterBossClaw
@onready var left_claw_health: BossHealth = $CanvasLayer/HBoxContainer/LeftClawHealth as BossHealth
@onready var right_claw_health: BossHealth = $CanvasLayer/HBoxContainer/RightClawHealth as BossHealth

func _ready():
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
	left_claw_health.configure("Left claw", 500)
	right_claw_health.configure("Right claw", 500)

func handle_hit():
	state_machine.transition_to(hurt_state)

func handle_claw_destroy(claw: LobsterBossClaw):
	state_machine.transition_to(claw_destroy_state, { "claw_destroyed": claw })

func die():
	super.die()
