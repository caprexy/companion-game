extends Node2D  # attach to your Shotgun node

@export var bullet_scene: PackedScene         # The bullet scene
@export var fire_rate: float = 0.55           # Seconds between shots
@export var sprite_radius: float = 16                # Distance from player
@export var sprite_default_facing_left: bool = true
@export var bullets_per_shot: int = 5         # Number of bullets per blast
@export var spread_angle: float = 25.0        # Spread in degrees

var is_firing: bool = false
var time_since_last_fire: float = 0.0

# Reference to the shotgun itself
@onready var shotgun: Node2D = self

func _process(delta: float) -> void:
	var player: Node2D = get_parent()
	_update_position_and_rotation(player)
	
	if is_firing:
		time_since_last_fire -= delta
		if time_since_last_fire <= 0.0:
			shoot()
			time_since_last_fire = fire_rate

func _update_position_and_rotation(player: Node2D) -> void:
	# Direction from player to mouse
	var dir: Vector2 = (get_global_mouse_position() - player.global_position).normalized()

	# Position the shotgun at a fixed sprite_radius from player
	global_position = (player.global_position + dir * sprite_radius).round()

	# Rotate and flip based on direction
	if sprite_default_facing_left:
		if dir.x >= 0:
			shotgun.scale.x = -1
			rotation = dir.angle()
		else:
			shotgun.scale.x = 1
			rotation = dir.angle() + PI
	else:
		if dir.x <= 0:
			shotgun.scale.x = -1
			rotation = dir.angle()
		else:
			shotgun.scale.x = 1
			rotation = dir.angle() + PI

func shoot() -> void:
	var player_pos: Vector2 = get_parent().global_position
	var aim_dir: Vector2 = (get_global_mouse_position() - player_pos).normalized()

	# Spread in radians
	var spread_radians: float = deg_to_rad(spread_angle)

	# Fire bullets with random angle within spread
	for i in bullets_per_shot:
		var bullet = bullet_scene.instantiate() as Node2D
		get_tree().current_scene.add_child(bullet)
		
		# Position bullet at shotgun location
		bullet.global_position = global_position
		
		# Random angle offset within -spread/2 .. +spread/2
		var angle_offset: float = randf_range(-spread_radians / 2, spread_radians / 2)
		bullet.direction = aim_dir.rotated(angle_offset)
