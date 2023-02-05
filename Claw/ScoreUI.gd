extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var game_manager
# Called when the node enters the scene tree for the first time.
func _ready():
	game_manager = get_parent().get_node("GameManager")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	text = String(game_manager.score)
