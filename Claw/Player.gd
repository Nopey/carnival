extends Area2D

export var mouth_path: NodePath
onready var mouth = get_node(mouth_path)
export var speed: float = 200

signal bite(id)

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	walk(delta)
	gentle_spin()
	bob_for_turnips(delta)

func walk(delta):
	var input = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	# clamp input (unneeded?)
	var input_length = input.length()
	if input_length > 1:
		input /= input_length

	self.translate(input * speed * delta)

func gentle_spin():
	self.rotation = cos(OS.get_ticks_msec() / 1000.0 * 0.4) * 0.25 + 0.7

enum BobState {
	IDLE,
	DOWN,
	DOWN_HOLD, # hold at the bottom for a moment
	UP,
	UP_GOTCHA # got the turnip
}
var bob_state = BobState.IDLE
var state_progress = 0

const BOB_DOWN_LENGTH: float = 3.0
const BOB_DOWN_HOLD_LENGTH: float = 0.3

const BOB_IDLE_SCALE: float = 0.5
const BOB_DOWN_SCALE: float = 1.0

func bob_for_turnips(delta):
	state_progress += delta
	if is_state_done():
		transition_to(get_next_state())

	# set scale
	var from_scale = BOB_DOWN_SCALE
	var to_scale = BOB_DOWN_SCALE
	match bob_state:
		BobState.IDLE:
			from_scale = BOB_IDLE_SCALE
			to_scale = BOB_IDLE_SCALE
		BobState.DOWN:
			from_scale = BOB_IDLE_SCALE
		BobState.UP:
			to_scale = BOB_IDLE_SCALE
		BobState.UP_GOTCHA:
			to_scale = BOB_IDLE_SCALE
	var progress = state_progress / get_state_length()
	var scale = lerp(from_scale, to_scale, progress)
	self.scale = Vector2(scale, scale)

	# grab turnips
	if bob_state == BobState.DOWN_HOLD && !gotcha:
		for turnip in mouth.get_overlapping_areas():
			if not turnip is Turnip:
				continue
			turnip_in_mouth(turnip)
<<<<<<< Updated upstream
			
=======

	#for area in self.get_overlapping_areas():
		#if area is Bucket:
			#self.global_position = lerp(screen_center, self.global_position, pow(0.5, delta))

>>>>>>> Stashed changes
	# bump turnips out of the way
	if bob_state == BobState.DOWN:
		pass

func is_state_done():
	if bob_state == BobState.IDLE:
		return Input.is_action_just_pressed("ui_accept")
	else:
		return state_progress > get_state_length()

func get_state_length():
	match bob_state:
		BobState.DOWN:
			return 1.3
		BobState.DOWN_HOLD:
			return 0.2
		BobState.UP:
			return 1.6
		BobState.UP_GOTCHA:
			return 2
		_:
			return INF

func transition_to(state):
	if state == bob_state:
		# no-op
		return

	print("BobState transition: ", BobState.keys()[bob_state], " to ", BobState.keys()[state])

	# from-state
	state_progress -= get_state_length()
	match bob_state:
		BobState.IDLE:
			state_progress = 0
		BobState.UP_GOTCHA:
			gotcha.queue_free() # TODO: hold turnip in mouth
			gotcha = null
			# TODO: remove grabbed turnip, increase points

	bob_state = state

	# to-state
	# TODO: SET GRAPHICS
	match bob_state:
		BobState.DOWN:
			pass
		BobState.DOWN_HOLD:
			pass
		BobState.UP:
			pass
		BobState.UP_GOTCHA:
			$sfx.play()
			pass
		BobState.IDLE:
			pass

func get_next_state():
	match bob_state:
		BobState.IDLE:
			return BobState.DOWN
		BobState.DOWN:
			return BobState.DOWN_HOLD
		BobState.DOWN_HOLD:
			if gotcha:
				return BobState.UP_GOTCHA
			return BobState.UP
		BobState.UP:
			return BobState.IDLE
		BobState.UP_GOTCHA:
			return BobState.IDLE

var gotcha = null
func turnip_in_mouth(turnip: Turnip):
	if bob_state != BobState.DOWN_HOLD || gotcha:		
		return
	
	# The player has bit a turnip.		
	var turnip_transform = turnip.global_transform
	gotcha = turnip
	turnip.get_parent().remove_child(turnip)
	add_child(turnip)
	turnip.set_owner(self)
	turnip.global_transform = turnip_transform
	
	# Connect singal becuase we destroyed the original turnip.
	# warning-ignore:return_value_discarded
	connect("bite", turnip, "_on_Player_bite")
	emit_signal("bite", turnip.turnip_id)
	
