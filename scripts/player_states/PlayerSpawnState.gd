class_name PlayerSpawnState
extends PlayerState

@export var move_state: PlayerMoveState

const AIR_MOVE_SPEED = 200.0
var flash_tween: Tween
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var started_ground_delay := false

func enter(msg := {}) -> void:
	started_ground_delay = false
	player.z = -400.0
	start_invincible_flash()
	player.healthbar.value = Player.MAX_HEALTH
	
func physics_update(delta: float) -> void:
	var direction_x = Input.get_axis("move_left", "move_right")
	var direction_y = Input.get_axis("move_up", "move_down")	
	player.velocity = Vector2(direction_x * AIR_MOVE_SPEED, direction_y * AIR_MOVE_SPEED)

	player.z += player.z_velocity * delta
	player.z_velocity += gravity * delta

	if player.z >= 0:
		player.z = 0
		player.z_velocity = 0
		if direction_x == 0.0 and direction_y == 0.0:
			player.sprite.play("default")
		else:
			player.sprite.play("move")
		if !started_ground_delay:
			started_ground_delay = true
			start_ground_delay()
		return
		
func start_ground_delay():
	await get_tree().create_timer(0.5).timeout
	flash_tween.kill()
	state_machine.transition_to(move_state)
	
func exit():
	player.sprite.modulate.a = 1

func update(_delta: float) -> void:
	if player.z_velocity > 0:
		player.sprite.play("fall")

func start_invincible_flash():
	flash_tween = create_tween()
	flash_tween.tween_property(player.sprite, "modulate:a", 0.1, 0.2)
	flash_tween.tween_property(player.sprite, "modulate:a", 1, 0.2)
	flash_tween.set_loops()
	
