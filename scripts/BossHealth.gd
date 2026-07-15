class_name BossHealth
extends HBoxContainer

@onready var label = $Label as Label
@onready var healthbar = $Healthbar as ProgressBar

func configure_from_boss(boss: Boss):
	label.text = boss.boss_name
	healthbar.max_value = boss.max_health
	healthbar.value = healthbar.max_value

func take_damage(damage: int):
	healthbar.value -= damage
