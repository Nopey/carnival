extends Node2D
class_name GameManager

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var turnip: PackedScene = load("res://Claw/Turnip.tscn")
export(Array, PackedScene) var garbage = []
export var count_turnips : int = 0
export var count_garbage : int = 0
export var max_turnips : int = 10
export var max_garbage : int = 5
export var chance_to_spawn_garbage : float = 0.25
export var spawn_radius: Vector2 = Vector2(1920, 1080) / 3.0
export var start_time : float = 30 
export var time_reward: float = 5
export var time_penalty: float = 5
export var score : int = 0
onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var player = get_parent().get_node("Player")
	player.connect("bitGarbage", self, "_on_Player_bitGarbage")
	player.connect("bitTurnip", self, "_on_Player_bitTurnip")
	
	timer.start(start_time)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if(count_turnips < max_turnips):
		create_turnip()
		
	if(count_garbage < max_garbage):
		create_garbage()


func create_turnip():

	var new_turnip = turnip.instance()
	count_turnips = count_turnips + 1
	add_child(new_turnip)

	new_turnip.set_owner(self)
	new_turnip.global_position = get_random_position()
	
func create_garbage():
	
	if (rand_range(0, 1) > 1 - chance_to_spawn_garbage):
		var new_garbage = garbage[int(rand_range(0,garbage.size()))].instance()
		count_garbage = count_garbage + 1
		add_child(new_garbage)
		new_garbage.set_owner(self)
		new_garbage.global_position = get_random_position()	

func get_random_position():
	var pos = self.global_position + spawn_radius * Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0).normalized()
	return pos

func _on_Timer_timeout():
	# to do: game over
	pass
	
func _on_Player_bitTurnip():	
	count_turnips = count_turnips - 1	
	score = score + 1
	timer.start(timer.time_left + time_reward)
	
func _on_Player_bitGarbage():	
	count_garbage = count_garbage - 1
	score = score - 1
	timer.start(timer.time_left - time_penalty)
