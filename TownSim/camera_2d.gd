extends Camera2D

@export var zoom_step: float = 0.1	# How much to zoom per wheel notch
@export var pan_speed: float = 1.0	# Adjust if panning is too sensitive

var _dragging := false
var _last_mouse_pos := Vector2.ZERO

func _ready():
	enabled = true	# Make sure this camera is active

func _input(event):
	if event is InputEventMouseButton:
		# Zoom in/out with mouse wheel
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom *= (1.0 - zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom *= (1.0 + zoom_step)

		# Middle‑button press/release for panning
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				_dragging = true
				_last_mouse_pos = event.position
			else:
				_dragging = false

func _process(delta):
	if _dragging:
		var current_mouse_pos = get_viewport().get_mouse_position()
		var mouse_delta = _last_mouse_pos - current_mouse_pos

		# Multiply by pan_speed if you want more/less responsiveness
		position += mouse_delta * pan_speed

		_last_mouse_pos = current_mouse_pos
