extends CharacterBody2D

# --- Configurable variables ---
@export var speed: float = 120.0             # Movement speed toward player
@export var circle_radius: float = 40.0      # Radius around player to stay within
@export var idle_move_strength: float = 40.0 # Max distance for idle wiggle
@export var idle_min_wait: float = 0.5       # Min time to pause between idle moves
@export var idle_max_wait: float = 2.0       # Max time to pause between idle moves

# Reference to player
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

# Internal variables
var idle_timer: float = 0.0
var idle_target: Vector2 = Vector2.ZERO
var is_moving_idle: bool = false

func _ready() -> void:
	_set_new_idle_target()

func _physics_process(delta: float) -> void:
	if player == null:
		return

	var vector_to_player: Vector2 = player.global_position - global_position
	var distance: float = vector_to_player.length()

	if distance > circle_radius:
		# Follow player if too far
		velocity = vector_to_player.normalized() * speed
		move_and_slide()
		# Reset idle state while following
		is_moving_idle = false
		idle_timer = 0.0
	else:
		# --- Idle movement inside the circle ---
		if is_moving_idle:
			# Move toward the idle target
			var to_target: Vector2 = idle_target - global_position
			if to_target.length() < 1.0:
				# Reached idle target, pause
				is_moving_idle = false
				idle_timer = randf_range(idle_min_wait, idle_max_wait)
				velocity = Vector2.ZERO
			else:
				velocity = to_target.normalized() * (speed * 0.2)  # slower movement for idle
				move_and_slide()
		else:
			# Countdown idle pause timer
			idle_timer -= delta
			if idle_timer <= 0.0:
				_set_new_idle_target()
			else:
				velocity = Vector2.ZERO

# --- Helper function to pick a new random idle target ---
func _set_new_idle_target() -> void:
	var angle: float = randf() * TAU
	var radius: float = randf() * idle_move_strength
	idle_target = global_position + Vector2(cos(angle), sin(angle)) * radius
	is_moving_idle = true
