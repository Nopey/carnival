extends Node2D

var initial_pos : Vector2
var final_pos : Vector2
var travel_distance : float = 100
var ready : bool = false
export var float_rate : float = 10

func setup(text, position):
	$Label.text = text
	initial_pos = position
	$Label.set_global_position(initial_pos)
	final_pos = initial_pos - Vector2(0.0, 1.0)*travel_distance	
	$Timer.connect("timeout", self, "_on_Timer_timeout")
	ready = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var current_position = $Label.get_global_position()
	if(current_position.y > final_pos.y && ready):
		$Label.set_global_position(lerp(current_position, final_pos, delta))
	
	pass
	
func _on_Timer_timeout():
	queue_free()
	pass
