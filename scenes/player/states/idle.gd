extends PhysicsState

var time_spent : float = 0.0
var easing: bool = false

func _left(_new_state : State): pass

func _entered(old_state : State):
	if old_state.name in ["Block"] :
		easing = true
	else:
		easing = false
	time_spent = 0.0
	anim_player.play("default/idle", 0.2)

func state_input(_event: InputEvent) -> void:
	pass

func state_physics(delta: float) -> void:
	var velocity := player.velocity
	var direction := player.direction

	# Add the gravity.
	velocity += player.get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector(
		replace_p("p&_left"),
		replace_p("p&_right"),
		replace_p("p&_up"),
		replace_p("p&_down")
	)
	#print("Player ",p," : ", direction)
	if direction:
		velocity = direction * player.SPEED * (ease(clampf(time_spent,0.0, 0.5)/0.5, 1.0) if easing else 1.0)
	else:
		velocity = lerp(velocity, Vector2.ZERO, 8.0 *delta)
	player.look_at(player.enemy.position)


	player.velocity = velocity
	player.direction = direction
	player.move_and_slide()

	time_spent += delta

	if Input.is_action_just_pressed(replace_p("p&_block")) :
		machine.change_state_from_name("Block")
	elif Input.is_action_just_pressed(replace_p("p&_dodge")) :
		machine.change_state_from_name("Dodge")
	elif Input.is_action_just_pressed(replace_p("p&_punch")) :
		machine.change_state_from_name("Punch")
	elif Input.is_action_just_pressed(replace_p("p&_special")) :
		machine.change_state_from_name("Special")

func state_process(_delta: float) -> void: pass
