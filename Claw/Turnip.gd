extends Area2D
class_name Turnip

export var turnip_id: int
export var flee_path: Vector2
export var flee_rate: float

export(Array, Texture) var turnip_arts

# Called when the node enters the scene tree for the first time.
func _ready():
	var turnip_art = turnip_arts[turnip_id % turnip_arts.size()]
	$Sprite.texture = turnip_art
	
	init_flee_params()
	
func init_flee_params():

	var unit_vec = Vector2(1.0,1.0)
	var rand_rotation = 2*PI*randf()				# to do: technically we need to init the rand somewhere
	flee_path = unit_vec.rotated(rand_rotation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	gentle_spin(delta)
	flee(delta)

func gentle_spin(delta):
	self.rotation += cos(OS.get_ticks_msec() / 1000.0 * (0.4 + turnip_id * 0.09 ) + turnip_id) * 0.1 * delta

# The turnips float in some random straight line path.
func flee(delta):
	self.translate(flee_path*delta*flee_rate)
	return

func _on_Player_bite(id):
	if self.turnip_id == id:
		$sfx.play()

func set_position(pos : Vector2):

	var transform = .get_transform()

	# There's no way this is the right way to do this, but lol game jam.
	transform.x = Vector2(pos.x, 0)
	transform.y = Vector2(0, pos.y)
