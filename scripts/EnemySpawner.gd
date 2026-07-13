class_name EnemySpawner
extends Node

@export var player_ref: Player
@export var enemy_scene: PackedScene
@export var enemies_folder: Node2D # all y-sorted entities need to be under the same node
var LEFT_SIDE: Vector2
var RIGHT_SIDE: Vector2
var spawn_config: WaveSpawnConfig
var spawn_timer: Timer

func _ready():
	var screen_size = get_viewport().size
	LEFT_SIDE = Vector2(-screen_size.x / 2 - 100, 100)
	RIGHT_SIDE = Vector2(screen_size.x / 2 + 100, 100)

func load_wave_config(wave_config: WaveSpawnConfig):
	self.spawn_config = wave_config

func start():
	if spawn_timer != null:
		spawn_timer.stop()
		spawn_timer.queue_free()
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_config.spawn_freq
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(spawn_enemies)
	add_child(spawn_timer)
	
func spawn_enemies():
	var configs = spawn_config.enemy_configs
	var num_enemies_to_spawn = randi_range(spawn_config.num_to_spawn_low, spawn_config.num_to_spawn_high)
	var num_enemies_left_to_spawn = (spawn_config.num_enemies_to_defeat - GameVariables.enemies_defeated_for_curr_wave) - get_num_enemies_on_screen()
	num_enemies_to_spawn = min(num_enemies_to_spawn, num_enemies_left_to_spawn)
	for i in range(0, num_enemies_to_spawn):
		var num_enemies_on_screen = get_num_enemies_on_screen()
		if get_num_enemies_on_screen() < spawn_config.max_enemies:
			var rand_config = configs.pick_random() as EnemyConfig
			var new_enemy = enemy_scene.instantiate() as Enemy
			new_enemy.initialize(player_ref, rand_config)
			enemies_folder.add_child(new_enemy)
			var starting_pos = LEFT_SIDE if randi_range(0, 1) == 0 else RIGHT_SIDE
			starting_pos.y = randi_range(100, 400)
			new_enemy.global_position = starting_pos

func get_num_enemies_on_screen():
	return enemies_folder.get_children().filter(func(c): return is_instance_valid(c) and c is Enemy).size()

func clear_curr_enemies():
	for c in get_children():
		if c is Enemy:
			c.queue_free()
