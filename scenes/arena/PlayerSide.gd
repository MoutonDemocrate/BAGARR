extends VBoxContainer
class_name PlayerSide

@export var player : Player

@export_group("Nodes")
@export var health_bar : ProgressBar
@export var special_bar : ProgressBar
@export var player_icon : TextureRect

func _ready() -> void:
	player.health_changed.connect(
		func (_old:float, new:float) :
			health_bar.value = new
	)
	player.special_gauge_changed.connect(
		func (_old:float, new:float) :
			special_bar.value = new
	)
	health_bar.set_value_no_signal(player.health)
	special_bar.set_value_no_signal(player.special_gauge)
