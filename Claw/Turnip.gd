extends Area2D
class_name Turnip
onready var turnip_id: int = randi()
export var flee_path: Vector2
export var flee_rate: float
export var flee_rate_rate: float

export(Array, Texture) var turnip_bodies
export(Array, Texture) var turnip_ripples

export(Array, AudioStream) var screams

const NOMINAL_FLEE_RATE = 40.0

export var target: Vector2 = Vector2(600, 400)
export var max_dist: float = 800  # ugly fallback for bucket failure
export var is_garbage: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_garbage:
		assert(turnip_bodies.size() == turnip_ripples.size())
		assert(turnip_bodies.size() > 0)
		var body = turnip_bodies[turnip_id % turnip_bodies.size()]
		$Sprite.texture = body
		var ripple = turnip_ripples[turnip_id % turnip_ripples.size()]
		$idle_particles.texture = ripple

	init_flee_params()

func init_flee_params():

	var unit_vec = Vector2(0.0,1.0)
	var rand_rotation = 2*PI*randf()				# to do: technically we need to init the rand somewhere

	flee_rate = NOMINAL_FLEE_RATE 								# to do: tune
	flee_path = unit_vec.rotated(rand_rotation)
	self.rotation = 2*PI*randf()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	gentle_spin(delta)
	flee(delta)
	dont_escape()
	sink()

func dont_escape():
	var offset = global_position - target
	if offset.length() > max_dist:
		flee_path = -offset.normalized()
		flee_rate = 100

func gentle_spin(delta):
	self.rotation += cos(OS.get_ticks_msec() / 1000.0 * (0.4 + turnip_id * 0.09 ) + turnip_id) * 0.1 * delta

# The turnips float in some random straight line path.
func flee(delta):
	if flee_rate > 0:
		flee_rate = lerp(NOMINAL_FLEE_RATE, flee_rate, pow(0.1, delta))
		flee_rate_rate = lerp(0, flee_rate_rate, pow(0.05, delta))
		flee_rate += flee_rate_rate * delta
		var effective_flee_rate = flee_rate / NOMINAL_FLEE_RATE
		effective_flee_rate *= effective_flee_rate
		effective_flee_rate *= NOMINAL_FLEE_RATE
		self.translate(flee_path*delta*flee_rate)
	else:
		flee_rate = 0
		flee_path = Vector2.ZERO

func sink():
	if flee_rate <= 0:
		return
	var progress = log(flee_rate / NOMINAL_FLEE_RATE)
	var scale = 1 + progress
	$Sprite.modulate = lerp(Color("#ffffff"), Color("#888888"), clamp(progress, 0.0, 1.0))
	self.scale = Vector2(scale, scale)
	self.z_index = scale
	$idle_particles.visible = flee_rate <= NOMINAL_FLEE_RATE * 1.1

func bump_other_turnip(area):
	if not "flee_rate" in area: # hack to detect turnips without mentioning turnip
		return
	var turnip = area
	var normal = (turnip.global_position - self.global_position).normalized()
	var tangent = normal.tangent()
	if self.flee_path.dot(normal) > 0:
		self.flee_path = self.flee_path.reflect(tangent)
	if turnip.flee_path.dot(normal) < 0:
		turnip.flee_path = turnip.flee_path.reflect(tangent)

	self.flee_path -= normal
	turnip.flee_path += normal

	self.flee_path += Vector2(randf(), randf()) * 0.2

	self.flee_path = self.flee_path.normalized()
	turnip.flee_path = turnip.flee_path.normalized()
	self.flee_rate_rate += 50

func _on_Player_bite():
	$idle_particles.emitting = false
	if is_garbage:
		pass # TODO: garbage eats
	else:
		$eat_particles.visible = true
	$Sprite.visible = false
	flee_rate = 0

func set_position(pos : Vector2):
	self.global_position = pos

func play_scream():
	if(!$sfx.playing && screams.size() > 0):
		var stream = screams[int(rand_range(0, screams.size()))]
		$sfx.set_stream(stream)
		$sfx.play()

func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	var offset = global_position - target
	flee_path = -offset.normalized()
	flee_rate = 100


func _on_Turnip_area_entered(area):
	bump_other_turnip(area)
