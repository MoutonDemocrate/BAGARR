extends Camera2D

@export var p1 : Player
@export var p2 : Player

func get_player_center() -> Vector2 :
	return p1.global_position + (p2.global_position - p1.global_position)/2.0

func get_player_distance() -> float :
	return (p2.global_position - p1.global_position).length()

func inverse_project(p:Vector2) -> Vector2:
	return ((p - self.global_position) / get_viewport_rect().size) * zoom * 2.0

func _process(delta: float) -> void:
	global_position = get_player_center()
	var distance := maxf(inverse_project(p1.global_position).length(), inverse_project(p2.global_position).length())
	#print(distance)
	if distance > 0.8 :
		zoom = (lerp(zoom, zoom / (1.0 + distance - 0.8), 2.0*delta) as Vector2).clamp(Vector2(0.1,0.1), Vector2(0.7,0.7))
	if distance < 0.5 :
		zoom = (lerp(zoom, zoom * (1.0 + (0.5 - distance)), 2.0*delta) as Vector2).clamp(Vector2(0.1,0.1), Vector2(0.7,0.7))
