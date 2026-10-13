extends ColorRect

var camera : Camera2D

func _ready() -> void:
	if not get_parent() is Camera2D :
		return
	else :
		camera = get_parent() as Camera2D


func _get_configuration_warnings() -> PackedStringArray:
	if not get_parent() is Camera2D :
		return ["This node must be the child of the camera !"]
	return []

func _process(_delta: float) -> void:
	var mat := self.material as ShaderMaterial
	mat.set_shader_parameter("camera_position", camera.global_position)
	mat.set_shader_parameter("zoom", camera.zoom.x)
	self.scale = 2.0 * Vector2.ONE / camera.zoom
