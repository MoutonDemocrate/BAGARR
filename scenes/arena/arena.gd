extends Node2D
class_name Arena

@export_group("Nodes")
@export var p1 : Player
@export var p2 : Player
@export var p1_start_pos : Marker2D
@export var p2_start_pos : Marker2D
@export var camera : ArenaCamera

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
var p1_victories := 0
var p2_victories := 0

signal player_dead(p:Player)

func _ready() -> void:
	p1 = Player.create(1, MatchInfo.p1_kit)
	p2 = Player.create(2, MatchInfo.p2_kit)
	add_child(p1)
	add_child(p2)
	
	camera.p1 = p1
	camera.p2 = p2
	
	p1.player_dead.connect(player_dead.emit.bind(p1))
	p2.player_dead.connect(player_dead.emit.bind(p2))
	p1.global_position = p1_start_pos.global_position
	p2.global_position = p2_start_pos.global_position

	side_p1.hide()
	side_p2.hide()

	await set_loop()
	
	SceneTransition.change_scene.bind("res://scenes/main_menu/main_menu.tscn")

func set_loop() -> void:
	Music.play_from_path("res://assets/sounds/music/battle_theme.tres")
	while round_number < MatchInfo.round_total :
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
		if dead.p == 2 :
			re_player_label.text = "Player 1"
			p1_victories += 1
		else :
			re_player_label.text = "Player 2"
			p2_victories += 1
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
