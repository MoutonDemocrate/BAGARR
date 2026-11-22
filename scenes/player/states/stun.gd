extends PhysicsState

var stun_mult : float = 1.0
var time_spent : float = 0.0
var easing: bool = false

func _left(_new_state : State):
	anim_player.speed_scale = 1.0

func _entered(old_state : State):
	time_spent = 0.0
	anim_player.speed_scale = 1.0 / stun_mult
	anim_player.play("default/stun", 0.05)
	print("P%s STUNNED !" % [str(player.p)])

func state_input(_event: InputEvent) -> void:
	pass

func state_physics(delta: float) -> void:
	var velocity := player.velocity
	var direction := player.direction

	velocity = lerp(velocity, Vector2.ZERO, 8.0 *delta)

	player.rotation = lerp_angle(
		player.rotation,
		player.global_position.angle_to_point(player.enemy.global_position),
		delta * 2.0
	)

	player.velocity = velocity
	player.direction = direction
	player.move_and_slide()

	time_spent += delta
	
	if time_spent >= player.mechanic.stun_duration * stun_mult :
		machine.change_state_from_name("Idle")

func state_process(_delta: float) -> void: pass
