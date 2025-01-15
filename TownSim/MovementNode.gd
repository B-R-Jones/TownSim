extends Node2D

signal movement_status_updated(move_status)

var nav_agent: NavigationAgent2D
var current_speed = 100.0  # was const SPEED

const STUCK_TIME_THRESHOLD := 2.0
const MOVEMENT_THRESHOLD := 1.0

var stuck_timer := 0.0
var last_position := Vector2.ZERO
var move_status = {
	"destination_coord": Vector2.ZERO,
	"at_destination": false,
	"is_stuck": false,
	"is_moving": false
}

func _ready():
	nav_agent = get_parent().get_node_or_null("NavigationAgent2D")
	if nav_agent == null:
		push_error("NavigationAgent2D node not found in the parent NPC.")
		return

	last_position = get_parent().global_position

func _physics_process(delta):
	if nav_agent.is_navigation_finished():
		move_status["at_destination"] = true
		move_status["is_moving"] = false
	else:
		var target_velocity = (nav_agent.get_next_path_position() - get_parent().global_position).normalized() * (100 * current_speed)
		get_parent().velocity = target_velocity
		get_parent().move_and_slide()
		nav_agent.set_velocity(get_parent().velocity)
		move_status["is_moving"] = true
		move_status["at_destination"] = false
		stuck_check(delta)

	emit_signal("movement_status_updated", move_status)

func stuck_check(delta):
	var distance_moved = get_parent().global_position.distance_to(last_position)
	if distance_moved >= MOVEMENT_THRESHOLD:
		stuck_timer = 0.0
	else:
		stuck_timer += delta

	if stuck_timer >= STUCK_TIME_THRESHOLD and move_status["at_destination"] == false:
		stuck_timer = 0.0
		move_status["is_stuck"] = true
		print("NPC is stuck")
	else:
		move_status["is_stuck"] = false

	last_position = get_parent().global_position

func set_destination(destination: Vector2):
	nav_agent.set_target_position(destination)
	move_status["destination_coord"] = destination

# NEW: Let the ThoughtNode set a new speed value
func set_current_speed(new_speed: float):
	current_speed = new_speed
