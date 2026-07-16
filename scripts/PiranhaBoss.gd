class_name PiranhaBoss
extends Boss

func _ready():
	boss_name = "Piranha"
	max_health = 500
	
func has_super_armor():
	return super.has_super_armor() or state_machine.state is BossBiteState or state_machine.state is BossChompLungeState
