extends Resource
class_name Kit

@export var id : StringName		= &"ERROR"
@export var kit_name : String	= "ERROR"
@export_multiline("A quick description of the kit.")
var kit_desc : String			= "This should not appear. Make a bug report."
@export var special_name : String		= "This Should Not Appear !"

@export var mechanic : Script
@export var block : Script
@export var dodge : Script
@export var punch : Script
@export var special : Script

func get_mechanic() -> MechanicPart :
	var new = mechanic.new()
	if new is MechanicPart :
		new.name = "Mechanic"
		return new as MechanicPart
	else :
		push_error("Kit '",kit_name,"' has an invalid mechanic part : '",mechanic.resource_path,"' is a ", mechanic.get_global_name())
		return null

func get_dodge() -> DodgePart :
	var new = dodge.new()
	if new is DodgePart :
		new.name = "Dodge"
		return new as DodgePart
	else :
		push_error("Kit '",kit_name,"' has an invalid dodge part : '",dodge.resource_path,"' is a ", dodge.get_global_name())
		return null

func get_block() -> BlockPart :
	var new = block.new()
	if new is BlockPart :
		new.name = "Block"
		return new as BlockPart
	else :
		push_error("Kit '",kit_name,"' has an invalid mechanic part : '",block.resource_path,"' is a ", block.get_global_name())
		return null

func get_punch() -> PunchPart :
	var new = punch.new()
	if new is PunchPart :
		new.name = "Punch"
		return new as PunchPart
	else :
		push_error("Kit '",kit_name,"' has an invalid punch part : '",punch.resource_path,"' is a ", punch.get_global_name())
		return null

func get_special() -> SpecialPart :
	var new = special.new()
	if new is SpecialPart :
		new.name = "Special"
		return new as SpecialPart
	else :
		push_error("Kit '",kit_name,"' has an invalid special part : '",special.resource_path,"' is a ", special.get_global_name())
		return null

static func check_kit_parts(kit:Kit) -> bool :
	if 		not kit.mechanic.new() is MechanicPart 	: return false
	elif 	not kit.block.new() is BlockPart 		: return false
	elif 	not kit.dodge.new() is DodgePart 		: return false
	elif 	not kit.punch.new() is PunchPart 		: return false
	elif 	not kit.special.new() is SpecialPart 	: return false
	return true

static var all_kits : Dictionary[StringName, Kit] = {}
static var kits_loaded : bool = false

static func load_all() -> Dictionary[StringName, Kit]:
	if kits_loaded:
		return all_kits
	kits_loaded = true

	for file in ResourceLoader.list_directory("res://scenes/player/kits/resources/"):
		if file.ends_with("/"):
			continue

		var kit := ResourceLoader.load("res://scenes/player/kits/resources/" + file) as Kit
		if kit == null:
			push_warning("Non-kit file in kit folder: " + file)
			continue

		var key := kit.id if kit.id != &"" else StringName(file.get_basename())
		if all_kits.has(key):
			push_error("Duplicate kit id '%s'" % key)
		all_kits[key] = kit

	return all_kits


static func get_kit(kit_id : StringName) -> Kit:
	Kit.load_all()
	return all_kits.get(kit_id)


static func all_as_array() -> Array[Kit]:
	Kit.load_all()
	var out : Array[Kit] = []
	out.assign(all_kits.values())
	return out


static func ids() -> Array[StringName]:
	Kit.load_all()
	var out : Array[StringName] = []
	out.assign(all_kits.keys())
	return out
