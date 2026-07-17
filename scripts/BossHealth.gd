class_name BossHealth
extends HBoxContainer

@onready var label = $Label as Label
@onready var healthbar = $Healthbar as ProgressBar

func configure(name_: String, max_value: int):
	label.text = name_
	healthbar.max_value = max_value
	healthbar.value = healthbar.max_value

func take_damage(damage: int):
	healthbar.value -= damage

func get_health():
	return healthbar.value
