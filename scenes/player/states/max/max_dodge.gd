extends DodgePart
class_name MaxDodge

const DODGE_SPEED : float = 3000.0
const DECAY : float = 10.0

const MAX_DISTANCE := 1000.0

var time_spent : float = 0.0
var dodge_direction : Vector2 = Vector2.ZERO

func dodged_damage(damage:Damage) -> Damage:
	damage.value = 0.0
	return damage

func _left(_new_state : State): pass

func _entered(_old_state : State):
	time_spent = 0.0

	# The player always looks at his enemy, so his local +x axis points at him
	# and his local +y axis is his own right side.
	var front := player.global_position.angle_to_point(player.enemy.global_position)
	var angle := Input.get_vector(
		replace_p("p&_left"),
		replace_p("p&_right"),
		replace_p("p&_up"),
		replace_p("p&_down")
	).angle()
	dodge_direction = Vector2.from_angle(Utils.clamp_angle(angle, front + PI/6, front - PI/6))

	player.direction = dodge_direction
	player.velocity = dodge_direction * DODGE_SPEED

	anim_player.play("max/dodge", 0.1)
	await anim_player.animation_finished
	machine.change_state_from_name("Idle")
	
func state_input(_event: InputEvent) -> void: pass

func state_physics(delta: float) -> void:
	var velocity := player.velocity

	# Add the gravity.
	velocity += player.get_gravity() * delta

	# Keep the propulsion going, but let it bleed off over the dodge.
	velocity = lerp(velocity, Vector2.ZERO, DECAY * delta)
	player.look_at(player.enemy.position)

	player.velocity = velocity
	player.direction = dodge_direction
	player.move_and_slide()

	time_spent += delta

func state_process(_delta: float) -> void: pass
