@icon("res://addons/mouton_fsm/assets/PhysicsMachine.svg")
extends Machine
## Extends Machine to integrate a physics-based FSM workflow.
## Switches through mutiple PhysicsState (as children of the machine)
class_name PhysicsMachine

@export var player : Player 
@export var anim_player : AnimationPlayer
@export var skeleton : Skeleton2D

func machine_input(event: InputEvent) -> void:
	current_state.state_input(event)

func machine_process(delta: float) -> void:
	current_state.state_process(delta)

func machine_physics(delta: float) -> void:
	current_state.state_physics(delta)

func _get_configuration_warnings():
	var warnings : Array[String] = []
	var state_found := false
	for child in self.get_children() :
		if child is PhysicsState :
			state_found = true
	if not state_found :
		if get_children() :
			warnings.append("It's recommended that all children of the PhysicsMachine be of class PhysicsState !")
		else :
			warnings.append("This Machine needs at least one PhysicsState child to properly function !")
	return warnings
