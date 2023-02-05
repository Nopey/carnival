extends Area2D
class_name Turnip
onready var turnip_id: int = randi()
export var flee_path: Vector2
export var flee_rate: float

export(Array, Texture) var turnip_arts

const NOMINAL_FLEE_RATE = 40.0

export var target: Vector2 = Vector2(600, 400)
export var max_dist: float = 800  # ugly fallback for bucket failure

# Called when the node enters the scene tree for the first time.
func _ready():
	var turnip_art = turnip_arts[turnip_id % turnip_arts.size()]
	$Sprite.texture = turnip_art
	
	init_flee_params()

func init_flee_params():

	var unit_vec = Vector2(0.0,1.0)
	var rand_rotation = 2*PI*randf()				# to do: technically we need to init the rand somewhere

	flee_rate = NOMINAL_FLEE_RATE 								# to do: tune
	flee_path = unit_vec.rotated(rand_rotation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	gentle_spin(delta)
	flee(delta)
	dont_escape()

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
		flee_rate = lerp(NOMINAL_FLEE_RATE, flee_rate, pow(0.5, delta))
		self.translate(flee_path*delta*flee_rate)
	else:
		flee_rate = 0
		flee_path = Vector2.ZERO

#const IDLE_SCALE: float = 1.0
#const SUNK_SCALE: float = 1.5

func sink():
	var scale = flee_rate / NOMINAL_FLEE_RATE
	var progress = scale / 5 + 0.5
	$Sprite.modulate = lerp(Color.brown, Color.white, progress)
	self.scale = Vector2(scale, scale)

func _on_Player_bite():
	$sfx.play()
	$idle_particles.emitting = false
	$eat_particles.visible = true
	flee_rate = 0

func set_position(pos : Vector2):
	self.global_position = pos


func _on_VisibilityNotifier2D_viewport_exited(viewport):
	var offset = global_position - target
	flee_path = -offset.normalized()
	flee_rate = 100
