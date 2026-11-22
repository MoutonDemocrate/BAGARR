extends MarginContainer
class_name CharacterSelectionScreen

@export var char_selector_p1: CharacterSelector
@export var char_selector_p2: CharacterSelector

func _ready() -> void:
	char_selector_p1.confirm_button.toggled.connect(
		func (pressed:bool) -> void:
			if char_selector_p2.confirm_button.button_pressed and pressed :
				both_players_ready()
	)
	char_selector_p2.confirm_button.toggled.connect(
		func (pressed:bool) -> void:
			if char_selector_p1.confirm_button.button_pressed and pressed :
				both_players_ready()
	)
	if char_selector_p1.confirm_button.button_pressed and char_selector_p2.confirm_button.button_pressed :
				both_players_ready()

func both_players_ready() -> void:
	char_selector_p1.lock = true
	char_selector_p2.lock = true
	
	MatchInfo.p1_kit = char_selector_p1.confirmed_kit()
	MatchInfo.p2_kit = char_selector_p2.confirmed_kit()
	
	SceneTransition.change_scene("res://scenes/arena/arena.tscn")
