extends CharacterBody2D

var health: int = 100
var speed: int = 100
@export var player: Node2D

func _process(delta):
	if health <= 0:
		queue_free()

func _physics_process(delta):
	if not player:
		return

	var direction = (player.global_position - global_position).normalized()
	var distance = global_position.distance_to(player.global_position)
	
	if distance > 12:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()  # no arguments in Godot 4

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.health -= 10
