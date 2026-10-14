extends SpecialPart

var time_spent := 0.0

func _left(_new_state : State):
	player.fist_area_l.monitoring = false
	player.fist_area_r.monitoring = false
	if anim_player.animation_finished.is_connected(_on_animation_finished) :
		anim_player.animation_finished.disconnect(_on_animation_finished)

func _entered(_old_state : State):
	if player.special_gauge < 100.0 :
		machine.change_state_from_name("Idle")
		return
	else :
		player.special_gauge = 0.0
	time_spent = 0.0

	if not anim_player.animation_finished.is_connected(_on_animation_finished) :
		anim_player.animation_finished.connect(_on_animation_finished)

	get_tree().create_timer(0.3).timeout.connect(
		func () :
			player.fist_area_r.monitoring = true
			player.fist_area_l.monitoring = true
	)

	# Small blend time so the punch does not get its first frames eaten.
	anim_player.speed_scale = 0.7
	anim_player.play("default/punch" + ("_r"), 0.05)

	var tween := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(player.skeleton, "scale", Vector2.ONE * 2.0, 0.2)

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

func state_process(_delta: float) -> void: pass

func _on_animation_finished(anim_name : StringName) -> void:
	anim_player.speed_scale = 1.0
	var tween := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(player.skeleton, "scale", Vector2.ONE, 0.2)
	machine.change_state_from_name("Idle")
