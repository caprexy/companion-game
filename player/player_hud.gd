extends CanvasLayer

# --- References to nodes ---
@export var player_node: NodePath
@onready var player: CharacterBody2D = get_node(player_node)

@export var weapon_node: NodePath
@onready var weapon: Node = get_node(weapon_node)  # Weapon node (e.g., Shotgun)

@onready var health_bar: ProgressBar = $Control/HealthBar
@onready var ammo_label: Label = $Control/AmmoCount  # Label for ammo

func _process(delta: float) -> void:
	if player == null:
		return

	# Update health
	health_bar.value = player.health

	# Update ammo display if weapon exists
	if weapon != null and "current_clip" in weapon and "clip_size" in weapon:
		ammo_label.text = str(weapon.current_clip) + " / " + str(weapon.clip_size)
