@icon("res://addons/mouton_fsm/assets/PhysicsState.svg")
@abstract
extends State
## Uses a Machine as its parent to receive inputs, data and define behaviour.
class_name PhysicsState

@onready var player : Player = (self.machine as PhysicsMachine).player
@onready var anim_player : AnimationPlayer = (self.machine as PhysicsMachine).anim_player
@onready var skeleton : Skeleton2D = (self.machine as PhysicsMachine).skeleton

func replace_p(s:String) -> String :
	if player and s.contains('p&_') :
		return s.replace('&',str(player.p))
	else :
		push_error(s, " is not a correct input action.")
		return s

@abstract func state_input(_event: InputEvent) -> void

@abstract func state_process(_delta: float) -> void

@abstract func state_physics(_delta: float) -> void
