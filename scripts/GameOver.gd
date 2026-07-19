class_name GameOver
extends Node2D

@export var victory_label: Label
@export var defeat_label: Label
@export var play_again_label: Label
@export var thanks_for_playing_label: Label
@export var try_again_label: Label

func _ready() -> void:
	if GameVariables.game_over_state == GameVariables.GameOverState.VICTORY:
		victory_label.show()
		thanks_for_playing_label.show()
		play_again_label.show()
		flash_prompt(play_again_label)
	else:
		defeat_label.show()
		try_again_label.show()
		flash_prompt(try_again_label)
	
func flash_prompt(label):
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0, 0.75)
	tween.tween_property(label, "modulate:a", 1, 0.75)
	tween.set_loops()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("start_game"):
		get_tree().change_scene_to_file("res://scenes/Game.tscn")
