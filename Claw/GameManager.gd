extends Node2D
class_name GameManager

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var turnip: PackedScene = load("res://Claw/Turnip.tscn")
export var text_floater_positive: PackedScene = load("res://Claw/TextFloaterGreen.tscn")
export var text_floater_negative: PackedScene = load("res://Claw/TextFloaterRed.tscn")
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
export var stats_string : String = "You devoured {turnips} of your kin and {garbage} pound(s) of garbage, you monster."
export var score_string : String = "Your score is {value}!"
export var add_string : String = "+{value}"
export var sub_string : String = "-{value}"
export var add_time_string : String = "+{value} sec"
export var sub_time_string : String = "-{value} sec"
export var floater_delay : float = 1.0

onready var audio_bus = preload("res://Claw/claw_mixer.tres")

var game_over : bool = false
var garbage_ate : int = 0
var turnips_ate : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	AudioServer.set_bus_layout(audio_bus)
	var player = get_parent().get_node("Player")
	player.connect("bitGarbage", self, "_on_Player_bitGarbage")
	player.connect("bitTurnip", self, "_on_Player_bitTurnip")
	
	timer.start(start_time)
	for _x in range(5):
		create_turnip(false)
		
	$game_over_text.hide()
	$score_text.hide()
	$stats_text.hide()
	$ScoreUI.show()
	$TimerUI.show()

const turnip_delay = 3
var next_turnip_timer

const garbage_delay = 5
var next_garbage_timer = garbage_delay

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	next_turnip_timer -= delta
	if count_turnips < max_turnips and next_turnip_timer < 0 and !game_over:
		create_turnip(false)
	
	next_garbage_timer -= delta	
	if count_garbage < max_garbage and next_garbage_timer < 0 and !game_over:
		create_garbage()
		
	increase_difficulty()
	
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
	
	if !game_over:
		game_over = true
		clean_up()
		$TimerUI.hide()
		$ScoreUI.hide()
		$gameover.play()
		$game_over_text.show()
		$score_text.text = score_string.format({"value": score})
		$score_text.show()
		$stats_text.text = stats_string.format({"turnips": turnips_ate, "garbage": garbage_ate})
		$stats_text.show()
		yield(get_tree().create_timer(5.0), "timeout")
		get_tree().change_scene("res://MainMenu/MainMenu.tscn")
	
func clean_up():
	var children = get_children()	
	
	for child in children:
		if child is Turnip:
			child.queue_free()
	
func _on_Player_bitTurnip(position):	
	
	timer.start(timer.time_left + time_reward)
	do_positive_floaters(position, floater_delay)
	
	count_turnips = count_turnips - 1	
	score = score + 1
	turnips_ate = turnips_ate + 1	
	
func _on_Player_bitGarbage(position):	
	
	timer.start(timer.time_left - time_penalty)
	do_negative_floaters(position, floater_delay)
	
	count_garbage = count_garbage - 1
	score = score - 1
	garbage_ate = garbage_ate + 1	
	
func do_positive_floaters(position, delay):
	
	create_text_floater_positive(add_string.format({"value": 1}), position)
	yield(get_tree().create_timer(delay), "timeout")
	create_text_floater_positive(add_time_string.format({"value": time_reward}), position)
	
func do_negative_floaters(position, delay):	
	create_text_floater_negative(sub_string.format({"value": 1}), position)
	yield(get_tree().create_timer(delay), "timeout")
	create_text_floater_negative(sub_time_string.format({"value": time_penalty}), position)
	
func create_text_floater_positive(text, position):
	var new_floater = text_floater_positive.instance()
	add_child(new_floater)
	new_floater.setup(text, position)
	
func create_text_floater_negative(text, position):
	var new_floater = text_floater_negative.instance()
	add_child(new_floater)
	new_floater.setup(text, position)
