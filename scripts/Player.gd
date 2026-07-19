class_name Player
extends CharacterBody2D

signal grab_escaped

@onready var game = get_node("/root/Game") as Game
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = %StateMachine
@onready var shadow: Sprite2D = $Shadow
@export var healthbar: ProgressBar
@export var lives_counter: Label # TODO: Replace this with better UI
@export var grabbed_state: PlayerGrabbedState
@export var hurt_state: PlayerHurtState
@export var death_state: PlayerDeathState
@export var audio_stream_player: AudioStreamPlayer

const MAX_JUMPS = 2
const MAX_LIVES = 3
const MAX_HEALTH = 100

var num_jumps_remaining = MAX_JUMPS
var uppercut_used = false;
var num_lives := MAX_LIVES

var z_velocity = 0.0
var z = 0.0 # altitude
var _shadow_base_scale: Vector2

func _ready() -> void:
	sprite.play("default")
	_shadow_base_scale = shadow.scale
	update_lives(0)
	pass
	
func _process(_delta: float) -> void:
	# animation
	sprite.position.y = z
	if velocity.x != 0 and state_machine.state is not PlayerJumpSlamState:
		sprite.flip_h = velocity.x < 0
	shadow.scale = _shadow_base_scale * IsometryUtils.scale_shadow_from(z)

	if z == 0:
		uppercut_used = false;

func _physics_process(_delta: float) -> void:
	velocity = IsometryUtils.scale_velocity(velocity)
	move_and_slide()

func damage(amount: int):
	state_machine.transition_to(hurt_state)
	healthbar.value -= amount
	if healthbar.value <= 0:
		kill()

func kill():
	state_machine.transition_to(death_state)
	update_lives(-1)
	healthbar.value = 0

func update_lives(amt: int):
	num_lives += amt
	lives_counter.text = "Lives: " + str(num_lives)
	if num_lives == 0:
		GameVariables.game_over_state = GameVariables.GameOverState.DEFEAT
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

# I-frames when the player is hurt or dead
func is_invincible():
	return state_machine.state is PlayerHurtState or \
		   state_machine.state is PlayerDeathState or \
		   state_machine.state is PlayerGrabbedState

func is_grabbed() -> bool:
	return state_machine.state is PlayerGrabbedState

# Shuts the player inside `hand` until they mash out or it lets go. Returns false if
# they are not in a state to be taken hold of.
func try_grab(hand: Node2D) -> bool:
	if is_grabbed():
		return false
	state_machine.transition_to(grabbed_state, {"hand": hand})
	return true

func release_from_grab() -> void:
	if is_grabbed():
		grabbed_state.release()

func get_sprite_size():
	return sprite.sprite_frames.get_frame_texture("default", 0).get_size() * sprite.scale

func play_attack_sfx():
	audio_stream_player.stream = GameVariables.attack_sfx
	audio_stream_player.play()
	
func play_jump_sfx():
	audio_stream_player.stream = GameVariables.jump_sfx
	audio_stream_player.play()
	
func play_dash_sfx():
	audio_stream_player.stream = GameVariables.dash_sfx
	audio_stream_player.play()

func play_hurt_sfx():
	audio_stream_player.stream = GameVariables.player_hurt_sfx
	audio_stream_player.play()
	
func play_respawn_sfx():
	audio_stream_player.stream = GameVariables.respawn_sfx
	audio_stream_player.play()

func play_death_sfx():
	audio_stream_player.stream = GameVariables.death_sfx
	audio_stream_player.play()
