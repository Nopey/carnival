extends Node2D
class_name GameManager


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(PackedScene) var turnip = load("res://Claw/Turnip.tscn")
export(Array, PackedScene) var turnips = [];
export var max_turnips : int = 10
export var spawn_radius: Vector2 = Vector2(300, 200)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if(turnips.size() < max_turnips):
		create_turnip()


func create_turnip():

	var new_turnip = turnip.instance()
	turnips.append(new_turnip)
	add_child(new_turnip)

	new_turnip.set_owner(self)
	new_turnip.global_position = get_random_position()


func get_random_position():
	var pos = self.global_position + spawn_radius * Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0).normalized()
	print(pos)
	return pos
