extends Label

onready var timer = get_parent().get_parent().get_node("Timer")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	text = String(round(timer.time_left* 100.0)/100.0)
	pass
