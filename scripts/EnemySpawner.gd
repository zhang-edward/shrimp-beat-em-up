class_name EnemySpawner
extends Node

@export var player_ref: Player
@export var enemies_folder: Node2D # all y-sorted entities need to be under the same node
var TOP_LEFT: Vector2
var TOP_MIDDLE: Vector2
var TOP_RIGHT: Vector2
var spawn_config: WaveSpawnConfig

func _ready():
	var screen_size = get_viewport().size
	TOP_LEFT = Vector2(-screen_size.x / 2 + 100, -screen_size.y / 2 - 100)
	TOP_MIDDLE = Vector2(0, -screen_size.y / 2 - 100)
	TOP_RIGHT = Vector2(screen_size.x / 2 - 100, -screen_size.y / 2 - 100)

func load_wave_config(wave_config: WaveSpawnConfig):
	self.spawn_config = wave_config

func start():
	var spawn_locations = [TOP_LEFT, TOP_MIDDLE, TOP_RIGHT]
	for group in spawn_config.enemy_groups:
		for i in range(group.count):
			var new_enemy = group.enemy_scene.instantiate() as Enemy
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

func clear_all_enemies():
	for c in enemies_folder.get_children():
		if c is Enemy:
			c.queue_free()
