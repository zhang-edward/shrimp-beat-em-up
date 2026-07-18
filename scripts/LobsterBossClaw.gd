class_name LobsterBossClaw
extends Boss

var lobster_boss: LobsterBoss
var health: BossHealth
var is_dead: bool = false

func _ready():
	sprite.play("idle")

func take_hit(hit: HitConfig, source: Node2D) -> void:
	if lobster_boss.has_super_armor():
		return
	health.take_damage(hit.damage)
	if health.get_health() == 0:
		lobster_boss.handle_claw_destroy(self)
		is_dead = true
	else:
		lobster_boss.handle_hit()
