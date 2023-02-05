extends Node2D
class_name GameManager


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(PackedScene) var turnip = load("res://Claw/Turnip.tscn")
export(Array, PackedScene) var turnips = [];
export var max_turnips : int = 10
export var spawn_radius: Vector2 = Vector2(300, 200)
export var start_time : float = 60 
export var time_reward: float = 5
export var score : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start(start_time)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):

	if(turnips.size() < max_turnips):
		create_turnip()


func create_turnip():

	var new_turnip = turnip.instance()
	turnips.append(new_turnip)
	add_child(new_turnip)

	new_turnip.set_owner(self)
	new_turnip.global_position = get_random_position()
	
	new_turnip.connect("die", self, "_on_Turnip_die")


func get_random_position():
	var pos = self.global_position + spawn_radius * Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0).normalized()
	return pos


func _on_Timer_timeout():
	# to do: game over
	pass
	
func _on_Turnip_die():
	score = score + 1
	$Timer.start($Timer.time_left + time_reward)
