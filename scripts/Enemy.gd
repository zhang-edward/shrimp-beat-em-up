class_name Enemy
extends CharacterBody2D

@export var move_speed := 100.0

@export var playerRef: Player
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	pass

func initialize(player: Player) -> void:
	playerRef = player

func _physics_process(delta: float) -> void:
	move_and_slide()
