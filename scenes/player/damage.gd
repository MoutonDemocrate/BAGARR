extends Object
class_name Damage

## Damage value
var value: float
## If set to more that 0.0, the damage will also stun the victim
var stun_mult: float
## Diverse damage flags. See [enum DamageFlags]
var flags: Array[DamageFlags] = []

func _init(i_value:float, i_stun_mult:float = 0.0, i_flags:Array[DamageFlags] = []) -> void:
	self.value = i_value
	self.stun_mult = i_stun_mult
	self.flags = i_flags

enum DamageFlags {	## Flags to add to the damage instance
	ABSOLUTE, 			## Absolute damage goes through everything
	PURE,				## Pure damage isn't reduced by armor or special mechanics
	IGNORES_BLOCK,		## Ignores the "is_blocking" state
	IGNORES_DODGE,		## Ignores the "is_dodging" state
	DOT,				## This is damage-over-time, and does not need to be blocked or ignored.
}

enum ReceivedStatus { ## Indicates how damage was treated by the victim
	TAKEN,				## Damage was taken by the player
	BLOCKED,			## Damage was blocked
	DODGED,				## Damage was dodged
	IGNORED,			## Damage was ignored (invicibility, etc...)
}

func _to_string() -> String:
	var string := str(value) + "d"
	if self.stun_mult != 0.0 :
		string += "x%1.1fs" % [stun_mult]
	if self.flags :
		for flag in flags :
			string += "+"
			match flag :
				DamageFlags.ABSOLUTE:		string += "Abs"
				DamageFlags.PURE:			string += "Pure"
				DamageFlags.IGNORES_BLOCK:	string += "NoBlock"
				DamageFlags.IGNORES_DODGE:	string += "NoDodge"
				DamageFlags.DOT:			string += "Dot"
	return string

static func str_status(status:ReceivedStatus) -> String:
	match status:
		ReceivedStatus.TAKEN:
			return "TAKEN"
		ReceivedStatus.BLOCKED:
			return "BLOCKED"
		ReceivedStatus.DODGED:
			return "DODGED"
		ReceivedStatus.IGNORED:
			return "IGNORED"
		_: 
			return "WHAT THE FUCK"
