extends Area2D
class_name Turnip

export var turnip_id: int

const turnip_arts = [
	"res://Claw/turnip_inanimate1.png",
	"res://Claw/turnip_inanimate2.png"
]


# Called when the node enters the scene tree for the first time.
func _ready():
	var turnip_art = turnip_arts[turnip_id % turnip_arts.size()]

	var texture = ImageTexture.new()
	var image = Image.new()
	image.load(turnip_art)
	texture.create_from_image(image)
	$Sprite.texture = texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	gentle_spin(delta)

func gentle_spin(delta):
	self.rotation += cos(OS.get_ticks_msec() / 1000.0 * (0.4 + turnip_id * 0.09 ) + turnip_id) * 0.1 * delta
