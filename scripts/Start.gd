class_name StartMenu
extends Node2D

@export var start_prompt: Label

func _ready():
	flash_start_prompt()
	
func flash_start_prompt():
	var tween = create_tween()
	tween.tween_property(start_prompt, "modulate:a", 0, 0.75)
	tween.tween_property(start_prompt, "modulate:a", 1, 0.75)
	tween.set_loops()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("start_game"):
		get_tree().change_scene_to_file("res://scenes/Game.tscn")
