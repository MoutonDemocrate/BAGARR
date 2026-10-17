@icon("res://addons/mouton_fsm/assets/StateMachine.svg")
extends Node
## Switches through mutiple States (as children of the machine)
class_name Machine

## Default state to fall back to (for when the current state is deleted)
@export var default_state : State

## Array of states currently tracked.
var states : Array[State]
## Current enabled state.
var current_state : State

## Called on state changed.
signal state_changed(from : State, to : State)

func _ready() -> void :
	refetch_states()
	current_state = default_state
	current_state.entered(default_state)
	current_state.state_entered.emit()

## Refreshes current states array.
func refetch_states() -> void :
	states = []
	for child in get_children() :
		if child is State and not child.is_queued_for_deletion():
			states.append(child)
	print("Refetched states : ",states)

## Changes the current state, returns old state
func change_state(new_state : State) -> State :
	var old_state : State = current_state
	current_state = new_state
	print("State changed from ",old_state.name ," to ",new_state.name)
	old_state.left(new_state)
	old_state.state_left.emit()
	state_changed.emit(old_state, new_state)
	new_state.entered(old_state)
	new_state.state_entered.emit()
	return current_state

## Get a state from a string
func get_state_from_name(state_name : String) -> State :
	var that_one_state : State
	for state in states :
		if state.name == state_name :
			that_one_state = state
	if not that_one_state :
		push_error("State '", state_name, "' doesn't exist.\n",
			"Acceptable states : ", str(states))
	return that_one_state

## Changes the current state from state namestring, returns old state
func change_state_from_name(new_state_name : String) -> State :
	return change_state(get_state_from_name(new_state_name))

## Get a state from its index
func get_state_from_index(state_index:int) -> State :
	return states[state_index % len(states)]

## Changes the current state from state index, returns old state
func change_state_from_index(new_state_index : int) -> State :
	return change_state(get_state_from_index(new_state_index))

## Adds a new state. Returns the new state on success.
func add_state(new_state : State) -> State :
	self.add_child(new_state)
	refetch_states()
	return new_state

## Deletes a state from the array.
func delete_state(state : State):
	state.queue_free()
	refetch_states()

func on_child_changed() -> void :
	update_configuration_warnings()

func _get_configuration_warnings():
	var warnings : Array[String] = []
	var state_found := false
	for child in self.get_children() :
		if child is State :
			state_found = true
	if not state_found :
		if get_children() :
			warnings.append("It's recommended that all children of the Machine be of class State !")
		else :
			warnings.append("This Machine needs at least one State child to properly function !")
	return warnings
