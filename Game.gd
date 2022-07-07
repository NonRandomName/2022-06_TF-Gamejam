extends Spatial

export(float) var MOVE_SPEED = 10
export(float) var ROTATION_SPEED = 2
enum VerticalInversion {NORMAL = 1, INVERTED = -1}
export(VerticalInversion) var VERTICAL_INVERSION = VerticalInversion.NORMAL
enum Handedness {LEFT, RIGHT}
export(Handedness) var HANDEDNESS = Handedness.LEFT setget set_handedness
enum ControlScheme {FLY, STICK}
export(ControlScheme) var CONTROLSCHEME = ControlScheme.FLY setget set_controlscheme

var lookaround_mode = false

func _ready():
	set_controlscheme(CONTROLSCHEME)

func set_controlscheme(value):
	CONTROLSCHEME = value
	set_handedness(HANDEDNESS)
	set_subtitle("Control scheme set to " + ControlScheme.keys()[CONTROLSCHEME])

func set_handedness(value):
	HANDEDNESS = value
	remove_actions()
	add_actions()
	set_subtitle("Handedness set to " + Handedness.keys()[HANDEDNESS])

func remove_actions():
	for action in ["backwards", "forwards", "left", "right", "fly_forwards", "fly_backwards"]:
		InputMap.action_erase_events(action)

func add_actions():
	var left = InputEventJoypadMotion.new()
	var right = InputEventJoypadMotion.new()
	var backwards = InputEventJoypadMotion.new()
	var forwards = InputEventJoypadMotion.new()
	var trigger = InputEventJoypadMotion.new()
	var button = InputEventJoypadButton.new()
	if HANDEDNESS == Handedness.LEFT:
		backwards.axis = JOY_AXIS_1
		forwards.axis = JOY_AXIS_1
		left.axis = JOY_AXIS_0
		right.axis = JOY_AXIS_0
		trigger.axis = JOY_ANALOG_L2
		button.button_index = JOY_L
	elif HANDEDNESS == Handedness.RIGHT:
		backwards.axis = JOY_AXIS_3
		forwards.axis = JOY_AXIS_3
		left.axis = JOY_AXIS_2
		right.axis = JOY_AXIS_2
		trigger.axis = JOY_ANALOG_R2
		button.button_index = JOY_R
	backwards.axis_value = -1
	forwards.axis_value = 1
	left.axis_value = -1
	right.axis_value = 1
	InputMap.action_add_event("backwards", backwards)
	InputMap.action_add_event("forwards", forwards)
	InputMap.action_add_event("left", left)
	InputMap.action_add_event("right", right)
	InputMap.action_add_event("fly_forwards", trigger)
	InputMap.action_add_event("fly_backwards", button)
	InputMap.action_add_event("toggle_lookaround", button)

func _physics_process(delta):
	if CONTROLSCHEME == ControlScheme.FLY:
		fly_process(delta)
	elif CONTROLSCHEME == ControlScheme.STICK:
		stick_process(delta)

func stick_process(delta):
	var speed = Input.get_axis("backwards", "forwards") * MOVE_SPEED
	var downwards = -MOVE_SPEED
	var direction = $Player.transform.basis.xform(Vector3(0, downwards, speed))
	var look_right_left = Input.get_axis("right", "left")
	var look_up_down = Input.get_axis("backwards", "forwards")
	$Player.rotate_y(look_right_left*delta*ROTATION_SPEED)
	if lookaround_mode:
		rotate_up_down(look_up_down*delta*VERTICAL_INVERSION*ROTATION_SPEED)
		if $Lab/girl3e_.is_inside_tree():
			$Lab/girl3e_.TITS += delta
			$Lab/girl3e_.TAIL += delta
			$Lab/girl3e_.EARS += delta
	else:
		$Player.move_and_slide(direction, Vector3.UP, true)

func fly_process(delta):
	var speed = Input.get_axis("fly_forwards", "fly_backwards") * MOVE_SPEED
	var downwards = -MOVE_SPEED
	var direction = $Player.transform.basis.xform(Vector3(0, downwards, speed))
	var look_up_down = Input.get_axis("backwards", "forwards")
	var look_right_left = Input.get_axis("right", "left")
	$Player.rotate_y(look_right_left*delta*ROTATION_SPEED)
	rotate_up_down(look_up_down*delta*VERTICAL_INVERSION*ROTATION_SPEED)
	$Player.move_and_slide(direction, Vector3.UP, true)

func rotate_up_down(amount):
	$Player/Camera.rotate_x(amount)
	$Player/Camera.rotation_degrees.x = clamp($Player/Camera.rotation_degrees.x, -60, 90)

func _input(event):
	if event.is_action("toggle_lookaround") and event.is_action_pressed("toggle_lookaround") and CONTROLSCHEME == ControlScheme.STICK:
		lookaround_mode = not lookaround_mode
		set_subtitle("Lookaround Mode is " + str(lookaround_mode))
	if event.is_action("toggle_handedness") and event.is_action_pressed("toggle_handedness"):
		if HANDEDNESS == Handedness.LEFT:
			set_handedness(Handedness.RIGHT)
		else:
			set_handedness(Handedness.LEFT)
	if event.is_action("toggle_control_scheme") and event.is_action_pressed("toggle_control_scheme"):
		if CONTROLSCHEME == ControlScheme.FLY:
			set_controlscheme(ControlScheme.STICK)
		else:
			set_controlscheme(ControlScheme.FLY)

func set_subtitle(text):
	if has_node("Player"):
		$Player.set_subtitle(text)
