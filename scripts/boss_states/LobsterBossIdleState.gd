class_name LobsterBossIdleState
extends BossIdleState

func enter(msg := {}) -> void:
	super.enter(msg)
	var lobster_boss = boss as LobsterBoss
	lobster_boss.left_claw.sprite.play("idle")
	lobster_boss.right_claw.sprite.play("idle")
