extends CharacterBody2D


const SPEED = 200.0
var health: int = 100

@onready var body_sprite: AnimatedSprite2D = $BodySprite
@onready var hair_sprite: AnimatedSprite2D = $HairSprite
@onready var shirt_sprite: AnimatedSprite2D = $ShirtSprite
@onready var shotgun: Node2D = $Shotgun

func _process(delta):
	shotgun.is_firing = Input.is_action_pressed("left_click")


func _physics_process(delta: float) -> void:

	var horizontal := Input.get_axis("move_left", "move_right")
	var vertical := Input.get_axis("move_up", "move_down")
	var direction := Vector2(horizontal, vertical).normalized()
	velocity = direction * SPEED
	
	if direction.x != 0:
		body_sprite.flip_h = direction.x < 0
		hair_sprite.flip_h = direction.x < 0
		shirt_sprite.flip_h = direction.x < 0

	move_and_slide()
	
func _input(event):
	if event.is_action_pressed("left_click"):
		shotgun.shoot()
