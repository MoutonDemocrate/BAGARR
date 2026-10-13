extends PhysicsState

var time_spent : float = 0.0

func _left(_new_state : State):
	player.is_blocking = false

func _entered(_old_state : State):
	anim_player.play("default/block", 0.1)
	get_tree().create_timer(0.1).timeout.connect(
		func () : player.is_blocking = true)

func state_input(event: InputEvent) -> void: pass

func state_physics(delta: float) -> void:
	var velocity := player.velocity
	var direction := player.direction
	var p := player.p

	# Add the gravity.
	velocity += player.get_gravity()/2.0 * delta

	velocity = lerp(velocity, Vector2.ZERO, 20.0 *delta)
	player.look_at(player.enemy.position)

	player.velocity = velocity
	player.direction = direction
	player.move_and_slide()

	time_spent += delta

	if not Input.is_action_pressed(replace_p("p&_block")) :
		machine.change_state_from_name("Idle")

func state_process(_delta: float) -> void: pass
