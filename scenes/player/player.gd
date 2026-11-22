extends CharacterBody2D
class_name Player

@export_range(1,2,1) var p : int = 1
@export var kit : Kit = load("res://scenes/player/kits/resources/johny.tres")
var mechanic : MechanicPart
var block_part : BlockPart
var dodge_part : DodgePart
var punch_part : PunchPart
var special_part : SpecialPart

@export var enemy : Player

@export_group("Nodes")
@export var fsm : PhysicsMachine
@export var anim_player : AnimationPlayer
@export var skeleton : Skeleton2D
@export var target_ik_l : Marker2D
@export var target_ik_r : Marker2D
@export var fist_area_l : Area2D
@export var fist_area_r : Area2D


var health := 100.0 :
	set(new):
		var old := health
		health = clampf(new, 0.0, 100.0)
		health_changed.emit(old, health)
		print("P",p," :: ", health, " HP")
		if health == 0.0 :
			player_dead.emit()
			modulate = Color(0.0, 0.0, 0.0, 0.545)

var special_gauge := 100.0 :
	set(new):
		var old := special_gauge
		special_gauge = clampf(new, 0.0, 100.0)
		special_gauge_changed.emit(old, special_gauge)

signal health_changed(old:float, new:float)
signal special_gauge_changed(old:float, new:float)
signal player_dead

signal uses_special(player:Player, special_name:String)
signal blocked_damage(damage:Damage)
signal dodged_damage(damage:Damage)
signal ignored_damage(damage:Damage)

const SPEED = 800.0

var is_punching : bool = false
var is_dodging : bool = false
var is_blocking : bool = false
var is_invicible : bool = false

var direction : Vector2

static func create(idx:int, kitx:Kit) -> Player:
	var player: Player = Player.new()
	player.p = idx
	player.kit = kitx
	return player

func _ready() -> void:
	block_part = kit.get_block()
	dodge_part = kit.get_dodge()
	punch_part = kit.get_punch()
	special_part = kit.get_special()

	fsm.add_child(block_part)
	fsm.add_child(dodge_part)
	fsm.add_child(punch_part)
	fsm.add_child(special_part)
	fsm.refetch_states()

	mechanic = kit.get_mechanic()

	fist_area_l.monitoring = false
	fist_area_r.monitoring = false

	reset()
	self.process_mode = Node.PROCESS_MODE_DISABLED

func _input(event: InputEvent) -> void:
	fsm.machine_input(event)

func _physics_process(delta: float) -> void:
	fsm.machine_physics(delta)

func use_special() -> void:
	if special_gauge != 100.0 or MatchInfo.special_animation_in_progress :
		return

	fsm.change_state_from_name("Special")
	uses_special.emit(self)

func hit(damage:Damage) -> Damage.ReceivedStatus :
	var og_damage := Damage.new(
		damage.value,
		damage.stun_mult,
		damage.flags
	)
	
	var parsed_damage = mechanic.parse_damage(damage)
	if parsed_damage is int :
		print("P%s : Parsed damage is ReceivedStatus, returning." % [str(p)])
		return parsed_damage
	elif parsed_damage is Damage :
		damage = parsed_damage
	
	var health_taken := damage.value * mechanic.armor
	var status := Damage.ReceivedStatus.TAKEN
	
	if Damage.DamageFlags.ABSOLUTE in damage.flags :
		if Damage.DamageFlags.PURE in damage.flags :
			health_taken = damage.value
			status = Damage.ReceivedStatus.TAKEN
		else :
			health_taken = damage.value * mechanic.armor
			status = Damage.ReceivedStatus.TAKEN
	
	elif is_invicible :
		health_taken = 0
		status = Damage.ReceivedStatus.IGNORED
	
	elif Damage.DamageFlags.PURE in damage.flags :
		health_taken = damage.value
		status = Damage.ReceivedStatus.TAKEN

	elif is_blocking :
		damage = block_part.blocked_damage(damage)
		if Damage.DamageFlags.IGNORES_BLOCK in damage.flags :
			health_taken = damage.value * mechanic.armor
			status = Damage.ReceivedStatus.TAKEN
		else :
			health_taken = damage.value * mechanic.armor
			status = Damage.ReceivedStatus.BLOCKED

	elif is_dodging :
		damage = dodge_part.dodged_damage(damage)
		if Damage.DamageFlags.IGNORES_DODGE in damage.flags :
			health_taken = damage.value * mechanic.armor
			status = Damage.ReceivedStatus.TAKEN
		else :
			health_taken = damage.value * mechanic.armor
			status = Damage.ReceivedStatus.DODGED

	if health_taken != 0 : health -= health_taken
	if status == Damage.ReceivedStatus.TAKEN and damage.stun_mult != 0.0 :
		fsm.get_state_from_name("Stun").stun_mult = damage.stun_mult
		fsm.change_state_from_name("Stun")
	match status :
		Damage.ReceivedStatus.BLOCKED:
			blocked_damage.emit()
		Damage.ReceivedStatus.DODGED:
			dodged_damage.emit()
		Damage.ReceivedStatus.IGNORED:
			ignored_damage.emit()
	print("Hit for %s dmg by %s -> %s (%s)" % [
		health_taken, 
		str(og_damage),
		Damage.str_status(status),
		Time.get_time_string_from_system()])
	return status

func activate_l_fist(monitor:=true) :
	fist_area_l.monitoring = monitor

func activate_r_fist(monitor:=true) :
	fist_area_r.monitoring = monitor

func reset() -> void:
	health = mechanic.max_health
	special_gauge = 100.0
	match p :
		1 : modulate = Color(1.0, 0.62, 0.791, 1.0)
		2 : modulate = Color(0.62, 1.0, 0.918, 1.0)
		_ : push_error("p = ", p, " is not a valid player number !")
