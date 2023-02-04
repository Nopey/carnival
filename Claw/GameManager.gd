extends Node

class_name GameManager


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(PackedScene) var turnip
export(Array, PackedScene) var turnips = [];
export var max_turnips : int


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if(turnips.size() < max_turnips):
		create_turnip()

	pass

func create_turnip():

	var new_turnip = turnip.instance()
	turnips.append(new_turnip)
	add_child(new_turnip)

	new_turnip.set_owner(self)
	new_turnip.set_position(get_random_position())

	pass

func get_random_position():
	
	# to do

	return Vector2(0.0, 0.0)

	pass
