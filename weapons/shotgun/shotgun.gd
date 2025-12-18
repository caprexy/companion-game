extends Node2D

@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.55
@export var sprite_radius: float = 16
@export var bullets_per_shot: int = 5
@export var spread_angle: float = 25.0

@export var clip_size: int = 8
@export var total_ammo: int = 32
@export var reload_time: float = 2.0

var current_clip: int = clip_size
var is_firing: bool = false
var time_since_last_fire: float = 0.0
var is_reloading: bool = false
var reload_timer: float = 0.0
var fire_buffer_after_reload: float = 0.1

@onready var shotgun_sprite: AnimatedSprite2D = $ShotgunSprite

func _process(delta: float) -> void:
	var player: Node2D = get_parent()
	if player == null:
		return

	_update_position_and_rotation(player)

	# Reload timer
	if is_reloading:
		reload_timer -= delta
		if reload_timer < reload_time and shotgun_sprite.animation != "reload_go_up":
			shotgun_sprite.play("reload_go_up")
		if reload_timer <= 0.0:
			_finish_reload()

	# Firing
	if is_firing:
		time_since_last_fire -= delta
		if can_fire():
			shoot()
			time_since_last_fire = fire_rate

	# Idle animation
	if not is_firing and not is_reloading:
		if shotgun_sprite.animation != "idle":
			shotgun_sprite.play("idle")

func _update_position_and_rotation(player: Node2D) -> void:
	var dir: Vector2 = (get_global_mouse_position() - player.global_position).normalized()
	global_position = (player.global_position + dir * sprite_radius).round()

	# Flip and rotate the sprite
	if dir.x >= 0:
		shotgun_sprite.scale.x = -1
		rotation = dir.angle()
	else:
		shotgun_sprite.scale.x = 1
		rotation = dir.angle() + PI

func shoot() -> void:
	if current_clip <= 0 and not is_reloading:
		_start_reload()
		return
	if not can_fire():
		return

	var player_pos: Vector2 = get_parent().global_position
	var aim_dir: Vector2 = (get_global_mouse_position() - player_pos).normalized()
	var spread_radians: float = deg_to_rad(spread_angle)

	for i in bullets_per_shot:
		var bullet = bullet_scene.instantiate() as Node2D
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
		var angle_offset: float = randf_range(-spread_radians/2, spread_radians/2)
		if "direction" in bullet:
			bullet.direction = aim_dir.rotated(angle_offset)

	current_clip -= 1

func can_fire() -> bool:
	return not is_reloading and current_clip > 0 and time_since_last_fire <= 0.0

func _start_reload() -> void:
	if is_reloading or current_clip == clip_size or total_ammo <= 0:
		return
	is_reloading = true
	reload_timer = reload_time
	time_since_last_fire = fire_buffer_after_reload
	shotgun_sprite.play("reload_idle_down")

func _finish_reload() -> void:
	is_reloading = false
	var needed: int = clip_size - current_clip
	var ammo_to_load: int = min(needed, total_ammo)
	current_clip += ammo_to_load
	total_ammo -= ammo_to_load
	shotgun_sprite.play("reload_go_down")

func reload() -> void:
	if current_clip < clip_size and not is_reloading and total_ammo > 0:
		_start_reload()
