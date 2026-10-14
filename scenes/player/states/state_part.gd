@abstract
extends PhysicsState
class_name StatePart

@abstract func _left(_new_state : State)
@abstract func _entered(_old_state : State)
@abstract func state_input(event: InputEvent) -> void
@abstract func state_physics(delta: float) -> void
@abstract func state_process(_delta: float) -> void
