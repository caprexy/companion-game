extends Node2D
class_name CompanionAiming

# --- Config ---
@export var aim_speed: float = 5.0                # radians/sec
@export var aim_margin_angle_deg: float = 12.0   # allowed error to fire
@export var rest_aim_angle: float = 0.0          # default resting direction
@export var max_target_range: float = 250.0      # max distance to aim/shoot

# References
@onready var shotgun: Node2D = get_parent()      # must be child of shotgun

# --- Runtime ---
var current_aim_angle: float = rest_aim_angle
var target_direction: Vector2 = Vector2.ZERO
var is_firing: bool = false
var fire_margin: float = deg_to_rad(aim_margin_angle_deg)

func update_aim(delta: float) -> void:
	if shotgun == null:
		return

	var enemy = _get_closest_visible_enemy(shotgun.global_position)
	if enemy != null:
		_aim_at_enemy(enemy, delta)
	else:
		_return_to_rest(delta)

	shotgun.target_direction = target_direction
	shotgun.is_firing = is_firing


# --- Private functions ---
func _aim_at_enemy(enemy: Node2D, delta: float) -> void:
	var enemy_vector = enemy.global_position - shotgun.global_position
	var target_angle = enemy_vector.angle()

	current_aim_angle = lerp_angle(current_aim_angle, target_angle, aim_speed * delta)

	var angle_diff = abs(wrapf(target_angle - current_aim_angle, -PI, PI))
	is_firing = angle_diff <= fire_margin

	target_direction = Vector2.from_angle(current_aim_angle)


func _return_to_rest(delta: float) -> void:
	var angle_diff = wrapf(rest_aim_angle - current_aim_angle, -PI, PI)
	current_aim_angle = lerp_angle(current_aim_angle, rest_aim_angle, aim_speed * delta)

	is_firing = false
	target_direction = Vector2(cos(current_aim_angle), sin(current_aim_angle))


func _get_closest_visible_enemy(pos: Vector2) -> Node2D:
	var closest: Node2D = null
	var smallest_dist = max_target_range
	var space = get_world_2d().direct_space_state

	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy == null:
			continue
		var dist_to_enemy = pos.distance_to(enemy.global_position)
		if dist_to_enemy > smallest_dist:
			continue
		if _has_line_of_sight(space, pos, enemy.global_position, enemy):
			smallest_dist = dist_to_enemy
			closest = enemy

	return closest


func _has_line_of_sight(space: PhysicsDirectSpaceState2D, from: Vector2, to: Vector2, target: Node2D) -> bool:
	var params = PhysicsRayQueryParameters2D.new()
	params.from = from
	params.to = to
	params.exclude = [self]
	params.collide_with_areas = false
	params.collide_with_bodies = true

	var hit = space.intersect_ray(params)
	return hit.is_empty() or hit.collider == target
