extends Spatial

var SPEED = 10
enum VerticalInversion {NORMAL = 1, INVERTED = -1}
export(VerticalInversion) var VERTICAL_INVERSION = VerticalInversion.NORMAL
enum HandedNess {LEFT, RIGHT}
export(HandedNess) var HANDEDNESS = HandedNess.LEFT setget set_handedness

func _ready():
	set_handedness(HANDEDNESS)

func set_handedness(value):
	HANDEDNESS = value
	remove_actions()
	add_actions()

func remove_actions():
	for action in ["backwards", "forwards", "left", "right", "move"]:
		InputMap.action_erase_events(action)

func add_actions():
	var left = InputEventJoypadMotion.new()
	var right = InputEventJoypadMotion.new()
	var backwards = InputEventJoypadMotion.new()
	var forwards = InputEventJoypadMotion.new()
	var trigger = InputEventJoypadMotion.new()
	if HANDEDNESS == HandedNess.LEFT:
		backwards.axis = JOY_AXIS_1
		forwards.axis = JOY_AXIS_1
		left.axis = JOY_AXIS_0
		right.axis = JOY_AXIS_0
		trigger.axis = JOY_ANALOG_L2
	elif HANDEDNESS == HandedNess.RIGHT:
		backwards.axis = JOY_AXIS_3
		forwards.axis = JOY_AXIS_3
		left.axis = JOY_AXIS_2
		right.axis = JOY_AXIS_2
		trigger.axis = JOY_ANALOG_R2
	backwards.axis_value = -1
	forwards.axis_value = 1
	left.axis_value = -1
	right.axis_value = 1
	InputMap.action_add_event("backwards", backwards)
	InputMap.action_add_event("forwards", forwards)
	InputMap.action_add_event("left", left)
	InputMap.action_add_event("right", right)
	InputMap.action_add_event("move", trigger)

func _physics_process(delta):
	var speed = Input.get_action_strength("move") * SPEED
	var direction = $Player.transform.basis.xform(Vector3(0, 0, -speed))
	var look_up_down = Input.get_axis("backwards", "forwards")
	var look_right_left = Input.get_axis("right", "left")
	$Player.rotate_y(look_right_left*delta)
	$Player/Camera.rotate_x(look_up_down*delta*VERTICAL_INVERSION)
	$Player.move_and_slide(direction, Vector3.UP)
