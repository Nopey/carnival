extends Area2D

onready var mouth = $Mouth
export var speed: float = 200

var time_remaining  = 60.0
var points = 0

export var screen_center: Vector2 = Vector2(1920, 1080) / 2.0
export var allowed_region: Vector2 = Vector2(300, 200)

signal bitGarbage()
signal bitTurnip()

# Called when the node enters the scene tree for the first time.
func _ready():
	transition_to(BobState.IDLE)
	$chewing.play()		# hack


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	walk(delta)
	gentle_spin()
	bob_for_turnips(delta)

	var mouth_art = bob_mouths[bob_state]
	if mouth_art is Array:
		var idx = (state_progress * ANIM_SPEED) as int % mouth_art.size()
		mouth_art = mouth_art[idx]
	$Mouth/Sprite.texture = mouth_art


func walk(delta):
	var input = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	# limit within edges of board
	var offset = global_position - screen_center;
	if (offset / allowed_region).length() > 1:
		var normal = offset.normalized()
		var dot = input.dot(normal)
		if dot > 0:
			input -= dot * normal
	# clamp input (unneeded?)
	var input_length = input.length()
	if input_length > 1:
		input /= input_length

	self.translate(input * speed * delta)

func gentle_spin():
	self.rotation = (self.global_position.x - screen_center.x) / 2000.0

enum BobState {
	IDLE,
	DOWN,
	DOWN_HOLD, # hold at the bottom for a moment
	UP,
	UP_GOTCHA, # got the turnip
	UP_GARBAGE # got garbage, yuck!
}

onready var bob_mouths = {
	BobState.IDLE:			load("res://Claw/carrot_face.png"),
	BobState.DOWN:			load("res://Claw/carrot_face_down.png"),
	BobState.DOWN_HOLD:		load("res://Claw/carrot_face_down_hold.png"),
	BobState.UP:			load("res://Claw/carrot_face.png"),
	# two images: animates chewing
	BobState.UP_GOTCHA:		[load("res://Claw/carrot_face_down_hold.png"), load("res://Claw/carrot_face_down.png")],
	BobState.UP_GARBAGE:	load("res://Claw/carrot_face_distress.png"),
}
# speaking of chewing
const ANIM_SPEED = 8

var bob_state = BobState.IDLE
var state_progress = 0

const BOB_DOWN_LENGTH: float = 2.5
const BOB_DOWN_HOLD_LENGTH: float = 0.5

const BOB_IDLE_SCALE: float = 1.0
const BOB_DOWN_SCALE: float = 1.5

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
		BobState.UP_GARBAGE:
			to_scale = BOB_IDLE_SCALE
	var progress = state_progress / get_state_length()
	var scale = lerp(from_scale, to_scale, progress)
	self.scale = Vector2(scale, scale)
	var tint = lerp(Color("#081515"), Color.white, clamp(2.1 - scale, 0.0, 1.0))
	$BodySprite.modulate = tint
	$Mouth/Sprite.modulate = tint
	$"../Bucket/Sprite".modulate = tint

	# grab turnips
	if bob_state == BobState.DOWN_HOLD && !gotcha:
		var best_turnip: Turnip = null
		var best_distance: float
		for area in mouth.get_overlapping_areas():
			# only eat turnips (and garbage)
			if not area is Turnip:
				continue
			var turnip: Turnip = area
			# no eating sunk turnips
			if turnip.flee_rate > turnip.NOMINAL_FLEE_RATE * 1.5:
				continue
			# closest turnip is the only one we eat
			var turnip_dist: float = turnip.global_position.distance_to(self.global_position)
			if best_turnip and best_distance < turnip_dist:
				continue
			best_turnip = turnip
			best_distance = turnip_dist
		if best_turnip:
			$splash.play()
			turnip_in_mouth(best_turnip)			
		else:
			$emptybite.play()
			$splash.play()

	# bump turnips out of the way
	if bob_state == BobState.DOWN || bob_state == BobState.UP || bob_state == BobState.UP_GOTCHA || bob_state == BobState.UP_GARBAGE:
		for area in self.get_overlapping_areas():
			if not area is Turnip:
				continue
			var turnip: Turnip = area
			if mouth.overlaps_area(turnip):
				continue
			var bump = (turnip.global_position - self.global_position).normalized()
			turnip.flee_path = (turnip.flee_path + bump * delta * 500 / turnip.flee_rate).normalized()
			turnip.flee_rate += delta * 200
			turnip.flee_rate_rate = 100
			
			if(bob_state == BobState.DOWN):
				turnip.play_scream()

func is_state_done():
	if bob_state == BobState.IDLE:
		return Input.is_action_just_pressed("ui_accept")
	elif bob_state == BobState.DOWN_HOLD && gotcha:
		return state_progress > 0.1
	else:
		return state_progress > get_state_length()

func get_state_length():
	match bob_state:
		BobState.DOWN:
			return 0.9
		BobState.DOWN_HOLD:
			return 0.3
		BobState.UP:
			return 1.4
		BobState.UP_GOTCHA:
			return 2.0
		BobState.UP_GARBAGE:
			return 2.4
		_:
			return INF

func transition_to(state):
	# from-state
	state_progress -= get_state_length()
	match bob_state:
		BobState.IDLE:
			state_progress = 0
		BobState.UP_GOTCHA:
			emit_signal("bitTurnip")
			score.text = str(points)

			gotcha.queue_free()
			gotcha = null
		BobState.UP_GARBAGE:
			emit_signal("bitGarbage")
			score.text = str(points)

			gotcha.queue_free()
			gotcha = null

	bob_state = state
	
	if(state == BobState.IDLE):
		$chewing.stream_paused = true	 # hack

	# to-state
	match bob_state:
		BobState.UP_GOTCHA:
			$bite_sfx.play()

func get_next_state():
	match bob_state:
		BobState.IDLE:
			return BobState.DOWN
		BobState.DOWN:
			return BobState.DOWN_HOLD
		BobState.DOWN_HOLD:
			if gotcha && gotcha.is_garbage:
				return BobState.UP_GARBAGE
			elif gotcha:
				return BobState.UP_GOTCHA
			return BobState.UP
		BobState.UP:
			return BobState.IDLE
		BobState.UP_GOTCHA:
			return BobState.IDLE
		BobState.UP_GARBAGE:
			return BobState.IDLE

var gotcha = null
func turnip_in_mouth(turnip: Turnip):
	if bob_state != BobState.DOWN_HOLD || gotcha:
		return

	# The player has bit a turnip.
	var turnip_transform = turnip.global_transform
	gotcha = turnip
	# reparent
	turnip.get_parent().remove_child(turnip)
	add_child(turnip)
	turnip.set_owner(self)
	turnip.global_transform = turnip_transform
	$chewing.stream_paused = false	
	
	turnip._on_Player_bite()
