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
export var score_string : String = "You devoured, %s of your kin, you monster."

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var player = get_parent().get_node("Player")
	player.connect("bitGarbage", self, "_on_Player_bitGarbage")
	player.connect("bitTurnip", self, "_on_Player_bitTurnip")
	
	timer.start(start_time)
	for _x in range(5):
		create_turnip(false)

const turnip_delay = 3
var next_turnip_timer

const garbage_delay = 5
var next_garbage_timer = garbage_delay

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	next_turnip_timer -= delta
	if count_turnips < max_turnips and next_turnip_timer < 0:
		create_turnip(false)
	
	next_garbage_timer -= delta	
	if(count_garbage < max_garbage && next_garbage_timer < 0):
		create_garbage()
		
	increase_difficulty()
	
# to do: this is a bad curve
func increase_difficulty():
	
	if(score > 0):
		var new_chance = chance_to_spawn_garbage * score
		if (new_chance < 1.0):
			chance_to_spawn_garbage = new_chance
		else:
			chance_to_spawn_garbage = 1.0

func create_turnip(is_onready: bool):

	var new_turnip = turnip.instance()
	count_turnips = count_turnips + 1
	add_child(new_turnip)

	new_turnip.set_owner(self)
	new_turnip.global_position = get_random_position()
	
	if not is_onready:
		new_turnip.flee_rate *= 2
		new_turnip.flee_rate_rate += 15
	next_turnip_timer = turnip_delay

func create_garbage():
	
	if (rand_range(0, 1) > 1 - chance_to_spawn_garbage):
		var new_garbage = garbage[int(rand_range(0,garbage.size()))].instance()
		count_garbage = count_garbage + 1
		add_child(new_garbage)
		new_garbage.set_owner(self)
		new_garbage.global_position = get_random_position()
		
	next_garbage_timer = garbage_delay

func get_random_position():
	var pos = self.global_position + spawn_radius * Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0).normalized()
	return pos

func _on_Timer_timeout():
	clean_up()
	$gameover.play()
	$TimerUi.hide()
	get_parent().get_node("Score").hide()	
	$game_over_label.show()
	$score.text = score_string % score
	$score.show()
	
func clean_up():
	var children = get_children()	
	
	for child in children:
		if child is Turnip:
			child.queue_free()
	
func _on_Player_bitTurnip():	
	count_turnips = count_turnips - 1	
	score = score + 1
	timer.start(timer.time_left + time_reward)
	
func _on_Player_bitGarbage():	
	count_garbage = count_garbage - 1
	score = score - 1
	timer.start(timer.time_left - time_penalty)
