extends Area2D
class_name Turnip

export var turnip_id: int

export(Array, Texture) var turnip_arts

# Called when the node enters the scene tree for the first time.
func _ready():
	var turnip_art = turnip_arts[turnip_id % turnip_arts.size()]
	$Sprite.texture = load(turnip_art)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	gentle_spin(delta)

func gentle_spin(delta):
	self.rotation += cos(OS.get_ticks_msec() / 1000.0 * (0.4 + turnip_id * 0.09 ) + turnip_id) * 0.1 * delta
