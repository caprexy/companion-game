extends CharacterBody2D

# --- Configurable variables ---
@export var speed: float = 120.0           # Movement speed
@export var circle_radius: float = 40.0    # Radius of the circle around the player

# Reference to player
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player == null:
		return

	# Vector from companion to player
	var vector_to_player: Vector2 = player.global_position - global_position

	# Move toward the player if outside the circle
	if vector_to_player.length() > circle_radius:
		velocity = vector_to_player.normalized() * speed
		move_and_slide()
	else:
		# Inside the circle → stand still
		velocity = Vector2.ZERO
