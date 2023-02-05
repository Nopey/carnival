extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


onready var playteeth = [
	load("res://MainMenu/PLAYTooth.png"),
	load("res://MainMenu/PLAYToothB.png")
]
func _on_hover_start():
	$Sprite.texture = playteeth[1]


func _on_hover_end():
	$Sprite.texture = playteeth[0]

onready var claw_game = preload("res://Claw/Game.tscn")

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		get_tree().change_scene_to(claw_game)
