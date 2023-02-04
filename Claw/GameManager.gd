extends Node

class_name GameManager


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(Array, PackedScene) var turnips = [Turnip];
var max_turnips : int


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if(turnips.count < max_turnips):
		create_turnip()

	pass

func create_turnip():

	var turnip = Turnip
	turnip.position(0,0)
	turnips.append(Turnip)

	pass

func get_random_position():

	pass
