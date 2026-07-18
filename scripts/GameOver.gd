class_name GameOver
extends Node2D

@export var game_over_label: Label

func _ready() -> void:
	game_over_label.text = "You Lose" if GameVariables.game_over_state == GameVariables.GameOverState.DEFEAT else "You Win!"
