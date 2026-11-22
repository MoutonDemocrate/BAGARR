@abstract
extends Node
class_name MechanicPart

@export var move_speed: float :
	get = get_move_speed
@export var look_acceleration: float :
	get = get_look_acceleration
@export var max_health: float :
	get = get_max_health
@export var armor: float :
	get = get_armor

@export var stun_duration: float :
	get = get_stun_duration

func get_move_speed() -> float:
	return 800.0
func get_look_acceleration() -> float:
	return 1.0
func get_max_health() -> float:
	return 100.0
func get_armor() -> float:
	return 1.0
func get_stun_duration() -> float:
	return 0.5

## Returns either a Damage or a ReceivedStatus
func parse_damage(damage:Damage) -> Variant:
	return damage
