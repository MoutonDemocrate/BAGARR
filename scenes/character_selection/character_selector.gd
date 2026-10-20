extends MarginContainer
class_name CharacterSelector

@export var p : int = 1

@export_subgroup("Nodes")
@export var top_label: Label
@export var left_label: Label
@export var right_label: Label

@export var tagline_label: Label

@export var skin_achor: Control
@export var skeleton: Skeleton2D
@export var anim_player: AnimationPlayer

var kits: Array[Kit] = Kit.all_as_array()
var kit_id: int = 0 :
	set(new) :
		kit_id = new % len(kits)

func _ready() -> void:
	anim_player.play("default/idle")
	set_kit(kits[kit_id])

func set_kit(kit:Kit) -> void:
	print(self, " switching to kit : %s" % kit.kit_name)
	top_label.text = kit.kit_name
	top_label.add_theme_font_override("font", kit.font)
	tagline_label.text = kit.kit_desc

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("p&_left".replace('&',str(p))) :
		kit_id -= 1
		set_kit(kits[kit_id])
	if event.is_action_pressed("p&_right".replace('&',str(p))) :
		kit_id += 1
		set_kit(kits[kit_id])
