extends CharacterBody2D

# --- Movement ---
@export var movement_speed: float = 120.0
@export var player_circle_radius: float = 40.0
@export var idle_move_dist: float = 40.0
@export var idle_min_wait: float = 0.5
@export var idle_max_wait: float = 2.0
@export var min_follow_distance: float = 30.0   # back off from enemy

# References
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var shotgun: Node2D = $Shotgun
@onready var aiming: CompanionAiming = $Shotgun/CompanionAiming

# --- Idle movement ---
var idle_timer: float = 0.0
var idle_target: Vector2 = Vector2.ZERO
var is_moving_idle: bool = false

func _ready() -> void:
	_set_new_idle_target()


func _physics_process(delta: float) -> void:
	if player == null:
		return

	_follow_or_idle(delta)
	_update_aiming(delta)

func _follow_or_idle(delta: float) -> void:
	var to_player = player.global_position - global_position
	if to_player.length() > player_circle_radius:
		velocity = to_player.normalized() * movement_speed
		move_and_slide()
		is_moving_idle = false
		idle_timer = 0.0
	else:
		_handle_idle(delta)


func _handle_idle(delta: float) -> void:
	if is_moving_idle:
		var to_target = idle_target - global_position
		if to_target.length() < 1.0:
			is_moving_idle = false
			idle_timer = randf_range(idle_min_wait, idle_max_wait)
			velocity = Vector2.ZERO
		else:
			velocity = to_target.normalized() * movement_speed * 0.2
			move_and_slide()
	else:
		idle_timer -= delta
		if idle_timer <= 0.0:
			_set_new_idle_target()
		else:
			velocity = Vector2.ZERO


func _set_new_idle_target() -> void:
	var angle = randf() * TAU
	var radius = randf() * idle_move_dist
	idle_target = global_position + Vector2.from_angle(angle) * radius
	is_moving_idle = true


func _update_aiming(delta: float) -> void:
	if aiming:
		aiming.update_aim(delta)
