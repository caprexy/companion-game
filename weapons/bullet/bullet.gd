extends Node2D

var speed = 300
var direction = Vector2.ZERO

func _process(delta):
	position += direction * speed * delta

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		var parent = area.get_owner()
		parent.health -= 10
		self.queue_free()
	else:
		self.queue_free()



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		queue_free()
