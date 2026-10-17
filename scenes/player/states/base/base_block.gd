extends BlockPart
class_name BaseBlock

var time_spent : float = 0.0

func blocked_damage(damage:Damage) -> Damage:
	damage.value = damage.value * 0.2
	return damage

func _left(_new_state : State):
	player.is_blocking = false

func _entered(_old_state : State):
	anim_player.play("default/block", 0.1)
	get_tree().create_timer(0.1).timeout.connect(
		func () : player.is_blocking = true)

func state_input(_event: InputEvent) -> void: pass

func state_physics(delta: float) -> void:
	var velocity := player.velocity
	var direction := player.direction

	# Add the gravity.
	velocity += player.get_gravity()/2.0 * delta

	velocity = lerp(velocity, Vector2.ZERO, 20.0 *delta)

	player.rotation = rotate_toward(
		player.rotation,
		player.global_position.angle_to_point(player.enemy.global_position),
		delta * 1.0
	)

	player.velocity = velocity
	player.direction = direction
	player.move_and_slide()

	time_spent += delta

	if not Input.is_action_pressed(replace_p("p&_block")) :
		machine.change_state_from_name("Idle")

func state_process(_delta: float) -> void: pass
