extends Object
class_name Damage

var value: float
var flags: Array[DamageFlags] = []

func _init(i_value:float, i_flags:Array[DamageFlags] = []) -> void:
	self.value = i_value
	self.flags = i_flags

enum DamageFlags {
	ABSOLUTE, 			## Absolute damage goes through everything
	PURE,				## Pure damage isn't reduced by armor or special mechanics
	IGNORES_BLOCK, 		## Ignores the "is_blocking" state
	IGNORES_DODGE,		## Ignores the "is_dodging" state
	DOT,				## This is damage-over-time, and does not need to be blocked or ignored.
}

enum ReceivedStatus {
	TAKEN,				## Damage was taken by the player
	BLOCKED,			## Damage was blocked
	DODGED,				## Damage was dodged
	IGNORED,			## Damage was ignored (invicibility, etc...)
}
