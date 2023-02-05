extends RichTextLabel

var timer

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = get_parent().get_node("Timer")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	text = String(timer.time_left)
	pass
