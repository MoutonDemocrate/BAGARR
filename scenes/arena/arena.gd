extends Node2D
class_name Arena

@export_group("Game Settings")
@export var number_of_rounds : int = 3

@export_group("Nodes")
@export var p1 : Player
@export var p2 : Player
@export var p1_start_pos : Marker2D
@export var p2_start_pos : Marker2D
@export var camera : Camera2D

@export_subgroup("UI")
@export var ui_layer : CanvasLayer
@export var ui_anim_player : AnimationPlayer
@export var round_label : VBoxContainer
@export var round_number_label : Label
@export var round_end : VBoxContainer
@export var re_character_label : Label
@export var re_player_label : Label
@export var side_p1 : PlayerSide
@export var side_p2 : PlayerSide

var round_number : int = 0

signal player_dead(p:Player)

func _ready() -> void:
	p1.player_dead.connect(player_dead.emit.bind(p1))
	p2.player_dead.connect(player_dead.emit.bind(p2))
	p1.global_position = p1_start_pos.global_position
	p2.global_position = p2_start_pos.global_position

	side_p1.hide()
	side_p2.hide()

	await set_loop()

func set_loop() -> void:
	while round_number < number_of_rounds :
		round_number_label.text = str(round_number + 1)
		ui_anim_player.play("round_start")
		await ui_anim_player.animation_finished
		side_p1.show()
		side_p2.show()
		p1.process_mode = Node.PROCESS_MODE_INHERIT
		p2.process_mode = Node.PROCESS_MODE_INHERIT
		var dead : Player = await player_dead
		side_p1.hide()
		side_p2.hide()
		re_character_label.text = "Johny Bagarr"
		re_player_label.text = "Player 2" if dead.p == 1 else "Player 1"
		ui_anim_player.play("round_end")
		await ui_anim_player.animation_finished
		round_number += 1
		await reset()
	return

func reset() -> void:
	p1.reset()
	p2.reset()

	var tween := create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(
		p1, "global_position",
		p1_start_pos.global_position, 1.0)
	tween.tween_property(
		p2, "global_position",
		p2_start_pos.global_position, 1.0)
	await tween.finished
