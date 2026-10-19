extends CanvasLayer
## Simple scene transition manager.
## Usage:  Transition.change_scene("res://levels/level_2.tscn", Transition.Type.FADE_ZOOM)

enum Type { FADE, FADE_ZOOM, SWIPE_LEFT, SWIPE_RIGHT }

var color := Color.BLACK   ## overlay color
var duration := 0.4        ## seconds, per half (cover + reveal)

var _rect := ColorRect.new()
var _snap := TextureRect.new()
var _busy := false


func _ready() -> void:
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS
	_snap.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_snap.stretch_mode = TextureRect.STRETCH_SCALE
	_snap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_snap.visible = false
	add_child(_snap)
	_rect.color = color
	_rect.visible = false
	add_child(_rect)


func change_scene(path: String, type: Type = Type.FADE, time := duration) -> void:
	if _busy:
		return
	_busy = true

	var vp := get_viewport().get_visible_rect().size
	var swipe := type == Type.SWIPE_LEFT or type == Type.SWIPE_RIGHT
	var dir := 1.0 if type == Type.SWIPE_LEFT else -1.0

	_rect.size = vp
	_rect.visible = true

	if type == Type.FADE_ZOOM:
		await RenderingServer.frame_post_draw
		_snap.texture = ImageTexture.create_from_image(get_viewport().get_texture().get_image())
		_snap.size = vp
		_snap.pivot_offset = vp * 0.5
		_snap.scale = Vector2.ONE
		_snap.visible = true

	# --- cover ---
	var t := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	if swipe:
		_rect.modulate.a = 1.0
		_rect.position.x = dir * vp.x
		t.tween_property(_rect, "position:x", 0.0, time)
	else:
		_rect.position = Vector2.ZERO
		_rect.modulate.a = 0.0
		t.tween_property(_rect, "modulate:a", 1.0, time)
		if type == Type.FADE_ZOOM:
			t.parallel().tween_property(_snap, "scale", Vector2(1.35, 1.35), time)
	await t.finished

	# --- swap ---
	get_tree().change_scene_to_file(path)
	_snap.visible = false
	_snap.texture = null
	await get_tree().process_frame

	# --- reveal ---
	var t2 := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	if swipe:
		t2.tween_property(_rect, "position:x", -dir * vp.x, time)
	else:
		t2.tween_property(_rect, "modulate:a", 0.0, time)
	await t2.finished

	_rect.visible = false
	_busy = false
