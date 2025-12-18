extends CanvasLayer

@export var player_node: NodePath
@onready var player: CharacterBody2D = get_node(player_node)

@onready var label: Label = $Control/Label
@onready var health_bar: ProgressBar = $Control/HealthBar

func _process(delta: float) -> void:
	if player == null:
		return
	label.text = str(player.health)
	health_bar.value = player.health
