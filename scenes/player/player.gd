extends CharacterBody2D
class_name Player

@export_range(1,2,1) var p : int = 1

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

var special_gauge := 0.0 :
	set(new):
		var old := special_gauge
		special_gauge = clampf(new, 0.0, 100.0)
		special_gauge_changed.emit(old, special_gauge)

signal health_changed(old:float, new:float)
signal special_gauge_changed(old:float, new:float)
signal player_dead

const SPEED = 800.0

var is_dodging : bool = false
var is_blocking : bool = false

var direction : Vector2

func _ready() -> void:
	reset()

	fist_area_l.body_entered.connect(on_fist_body_hit)
	fist_area_r.body_entered.connect(on_fist_body_hit)
	fist_area_l.area_entered.connect(on_fist_area_hit)
	fist_area_r.area_entered.connect(on_fist_area_hit)
	fist_area_l.monitoring = false
	fist_area_r.monitoring = false

	self.process_mode = Node.PROCESS_MODE_DISABLED

func _input(event: InputEvent) -> void:
	fsm.machine_input(event)

func _physics_process(delta: float) -> void:
	fsm.machine_physics(delta)

func on_self_hit(damage:float) -> void:
	if is_blocking or is_dodging :
		print("P",p," ", "dodged" if is_dodging else "blocked", " !")
		return
	health -= damage

func on_fist_body_hit(body:PhysicsBody2D) -> void:
	if body == self :
		return
	elif body == enemy :
		print("P",p," hit ", enemy)
		enemy.on_self_hit(10.0)

func on_fist_area_hit(area:Area2D) -> void:
	pass
	#if area.name.to_lower().contains("fist") :
		#if (area) == enemy :
			#print("P",p," hit ", enemy, "'s fists !")
			#if enemy.is_blocking :
				#enemy.on_self_hit(10.0)

func reset() -> void:
	health = 100.0
	special_gauge = 100.0
	match p :
		1 : modulate = Color(1.0, 0.62, 0.791, 1.0)
		2 : modulate = Color(0.62, 1.0, 0.918, 1.0)
		_ : push_error("p = ", p, " is not a valid player number !")
