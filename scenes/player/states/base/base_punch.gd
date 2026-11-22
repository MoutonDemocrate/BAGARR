extends PunchPart
class_name BasePunch

var time_spent : float = 0.0
var flip : bool = false

var punch_next : bool = false
var last_punch : float = 0
var consecutive_punches : int = 0
var banned : bool :
	get() :
		return Time.get_unix_time_from_system() - ban_time <= 1.5
		
var ban_time : float = 0

func _left(_new_state : State):
	player.is_punching = false
	if banned : return
	last_punch = Time.get_unix_time_from_system()
	player.fist_area_l.monitoring = false
	player.fist_area_r.monitoring = false
	if anim_player.animation_finished.is_connected(_on_animation_finished) :
		anim_player.animation_finished.disconnect(_on_animation_finished)
	player.fist_area_l.body_entered.disconnect(on_area_hit)
	player.fist_area_r.body_entered.disconnect(on_area_hit)
	
	anim_player.play("RESET_ARMS")

func _entered(_old_state : State):
	if banned :
		machine.change_state_from_name("Idle")
		print("BANNED")
		return
	
	if last_punch != 0 and Time.get_unix_time_from_system() - last_punch <= 0.5 :
		consecutive_punches += 1
		print("Cons Punches : %s" % consecutive_punches)
	elif Time.get_unix_time_from_system() - last_punch > 0.5 :
		consecutive_punches = 0
		print("Reset consecutive punches")
	
	if consecutive_punches >= 4 :
		ban_time = Time.get_unix_time_from_system()
		machine.change_state_from_name("Idle")
		consecutive_punches = 0
		print("Too many punches ! Banned !")
		return

	time_spent = 0.0
	punch_next = false
	flip = !flip
	player.is_punching = true

	if not anim_player.animation_finished.is_connected(_on_animation_finished) :
		anim_player.animation_finished.connect(_on_animation_finished)

	player.fist_area_l.body_entered.connect(on_area_hit)
	player.fist_area_r.body_entered.connect(on_area_hit)

	# Small blend time so the punch does not get its first frames eaten.
	anim_player.play("default/punch" + ("_r" if flip else "_l"), 0.05)


func on_area_hit(body: Node2D) -> void:
	if body == player.enemy :
		var damage := Damage.new(10.0, 1.0)
		player.enemy.hit(damage)

func state_input(_event: InputEvent) -> void: pass

func state_physics(delta: float) -> void:
	var velocity := player.velocity
	var direction := player.direction

	# Add the gravity.
	velocity += player.get_gravity() * delta

	direction = Input.get_vector(
		replace_p("p&_left"),
		replace_p("p&_right"),
		replace_p("p&_up"),
		replace_p("p&_down")
	)
	#print("Player ",p," : ", direction)
	if direction:
		velocity = direction * player.SPEED * 0.2
	else:
		velocity = lerp(velocity, Vector2.ZERO, 8.0 *delta)
	player.look_at(player.enemy.position)

	player.velocity = velocity
	player.direction = direction
	player.move_and_slide()

	time_spent += delta

	if Input.is_action_just_pressed(replace_p("p&_punch")) and not punch_next :
		if time_spent >= anim_player.current_animation_length*0.8 :
			print("Immediate punch !")
			machine.change_state_from_name("Punch")
			return
		elif time_spent >= anim_player.current_animation_length/2.0 :
			punch_next = true
			print("Punch again !")


func state_process(_delta: float) -> void: pass

func _on_animation_finished(anim_name : StringName) -> void:
	if punch_next :
		machine.change_state_from_name("Punch")
	else :
		machine.change_state_from_name("Idle")
