class_name EnemySpawner
extends Node

@export var player_ref: Player
@export var enemies_folder: Node2D # all y-sorted entities need to be under the same node
var TOP_LEFT: Vector2
var TOP_MIDDLE: Vector2
var TOP_RIGHT: Vector2
var spawn_config: WaveSpawnConfig
var spawn_timer: Timer

func _ready():
	var screen_size = get_viewport().size
	TOP_LEFT = Vector2(-screen_size.x / 2 + 100, -screen_size.y / 2 - 100)
	TOP_MIDDLE = Vector2(0, -screen_size.y / 2 - 100)
	TOP_RIGHT = Vector2(screen_size.x / 2 - 100, -screen_size.y / 2 - 100)

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
	var spawn_locations = [TOP_LEFT, TOP_MIDDLE, TOP_RIGHT]
	var enemy_scenes = spawn_config.enemy_scenes
	var num_enemies_to_spawn = randi_range(spawn_config.num_to_spawn_low, spawn_config.num_to_spawn_high)
	var num_enemies_left_to_spawn = (spawn_config.num_enemies_to_defeat - GameVariables.enemies_defeated_for_curr_wave) - get_num_enemies_on_screen()
	num_enemies_to_spawn = min(num_enemies_to_spawn, num_enemies_left_to_spawn)
	for i in range(0, num_enemies_to_spawn):
		var num_enemies_on_screen = get_num_enemies_on_screen()
		if get_num_enemies_on_screen() < spawn_config.max_enemies:
			var rand_scene = enemy_scenes.pick_random() as PackedScene
			var new_enemy = rand_scene.instantiate() as Enemy
			new_enemy.initialize(player_ref)
			enemies_folder.add_child(new_enemy)
			var rand_spawn_location = spawn_locations.pick_random()
			rand_spawn_location.x += randi_range(-40, 40)
			new_enemy.global_position = rand_spawn_location

func get_num_enemies_on_screen():
	return enemies_folder.get_children().filter(func(c): return is_instance_valid(c) and c is Enemy).size()

func clear_curr_enemies():
	for c in get_children():
		if c is Enemy:
			c.queue_free()
