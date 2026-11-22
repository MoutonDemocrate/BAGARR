extends BlockPart
class_name MaxBlock

var time_spent : float = 0.0
var blocked_times : int = 0
var loss_timer : float = 3.0

func blocked_damage(damage:Damage) -> Damage:
	damage.value = damage.value * 0.2
	if player.enemy.is_punching :
		blocked_times += 1
		loss_timer = 3.0
	if blocked_times >= 3:
		player.enemy.fsm.change_state_from_name("Stun")
		blocked_times = 0
	return damage

func _left(_new_state : State):
	player.is_blocking = false

func _entered(_old_state : State):
	anim_player.play("max/block", 0.1)
	get_tree().create_timer(0.1).timeout.connect(
		func () : player.is_blocking = true)
	get_tree().create_timer(0.4).timeout.connect(
		func () : player.is_blocking = false)
	await anim_player.animation_finished
	machine.change_state_from_name("Idle")

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
		delta * player.mechanic.look_acceleration
	)

	player.velocity = velocity
	player.direction = direction
	player.move_and_slide()

	time_spent += delta

func state_process(_delta: float) -> void: pass
