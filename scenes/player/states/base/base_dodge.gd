extends DodgePart
class_name BaseDodge

const DURATION : float = 0.5
const INVINCIBLE_DURATION : float = 0.4
const DODGE_SPEED : float = 2000.0
const DECAY : float = 2.0

const MAX_DISTANCE := 1000.0

var time_spent : float = 0.0
var dodge_direction : Vector2 = Vector2.ZERO

func _left(_new_state : State): pass

func _entered(_old_state : State):
	time_spent = 0.0
	get_tree().create_timer(0.05).timeout.connect(
		func () : player.is_dodging = true)
	get_tree().create_timer(0.05 + INVINCIBLE_DURATION).timeout.connect(
		func () : player.is_dodging = false)

	# The player always looks at his enemy, so his local +x axis points at him
	# and his local +y axis is his own right side.
	var side_axis := player.transform.y.normalized()
	var side := _pick_side(side_axis)

	var distance_to_enemy := (player.enemy.global_position - player.global_position).length()
	distance_to_enemy = clampf(distance_to_enemy, 0.0, MAX_DISTANCE) / MAX_DISTANCE

	dodge_direction = side_axis * side + player.transform.x.normalized() * lerpf(1.0, 0.0, distance_to_enemy**2.0)
	player.direction = dodge_direction
	player.velocity = dodge_direction * DODGE_SPEED

	anim_player.play("default/dodge", 0.1)

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

	if time_spent >= DURATION :
		machine.change_state_from_name("Idle")

func state_process(_delta: float) -> void: pass

# Returns +1.0 to dodge on the player's right, -1.0 on his left.
func _pick_side(side_axis : Vector2) -> float:
	var input := Input.get_vector(
		replace_p("p&_left"),
		replace_p("p&_right"),
		replace_p("p&_up"),
		replace_p("p&_down")
	)

	# Held stick first, last known movement second, right side as a last resort.
	var lateral := input.dot(side_axis)
	if absf(lateral) < 0.1 :
		lateral = player.direction.dot(side_axis)
	if absf(lateral) < 0.1 :
		return 1.0

	return signf(lateral)
