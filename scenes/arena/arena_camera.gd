extends Camera2D

@export var p1 : Player
@export var p2 : Player

## If true, the camera seeks the best area to be in and cover both players
@export var autonomous: bool = true

@export_group("Nodes")
@export var special_effects: Control
@export var special_label: Label

const SPECIAL_TIME_SCALE := 0.1

func _ready() -> void:
	special_effects.modulate = Color.TRANSPARENT

	p1.uses_special.connect(special)
	p2.uses_special.connect(special)

func get_player_center() -> Vector2 :
	return p1.global_position + (p2.global_position - p1.global_position)/2.0

func get_player_distance() -> float :
	return (p2.global_position - p1.global_position).length()

func inverse_project(p:Vector2) -> Vector2:
	return ((p - self.global_position) / get_viewport_rect().size) * zoom * 2.0

func get_new_zoom() -> Vector2 :
	var distance := maxf(inverse_project(p1.global_position).length(), inverse_project(p2.global_position).length())
	var zoom_mult := zoom
	if distance > 0.8 :
		zoom_mult /= (1.0 + distance - 0.8)
	elif distance < 0.5 :
		zoom_mult *= (1.0 + (0.5 - distance))
	return zoom_mult

func special(player:Player, _special_name: String = "Not Implemented") -> void:
	self.autonomous = false
	special_label.text = _special_name
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	tween.set_ignore_time_scale(true)
	tween.tween_property(Engine, "time_scale", SPECIAL_TIME_SCALE, 0.1)
	tween.tween_property(self, "zoom", Vector2.ONE, 0.4)
	tween.tween_property(self, "global_position", player.global_position, 0.2)
	tween.tween_property(special_effects, "modulate", Color.WHITE, 0.4)

	await get_tree().create_timer(2.0 * SPECIAL_TIME_SCALE).timeout

	tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.set_ignore_time_scale(true)
	tween.tween_property(Engine, "time_scale", 1.0, 0.5)
	tween.tween_property(self, "zoom", get_new_zoom(), 0.5)
	tween.tween_property(self, "global_position", get_player_center(), 0.5)
	tween.tween_property(special_effects, "modulate", Color.TRANSPARENT, 0.2)
	autonomous = true

	return

func _process(delta: float) -> void:
	if autonomous :
		zoom = (lerp(zoom, get_new_zoom(), 2.0*delta) as Vector2).clamp(Vector2(0.1,0.1), Vector2(0.7,0.7))
		global_position = get_player_center()
