class_name WaveSpawnConfig
extends Resource

# The enemies that make up this wave. Each group specifies an enemy scene and
# exactly how many of that enemy to spawn over the course of the wave.
@export var enemy_groups: Array[WaveEnemyGroup]

# Total number of enemies in the wave (the sum of every group's count). The wave
# is complete once this many enemies have been defeated.
func total_enemy_count() -> int:
	var total := 0
	for group in enemy_groups:
		total += group.count
	return total
