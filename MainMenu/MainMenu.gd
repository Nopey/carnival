extends Node

onready var claw_game = preload("res://Claw/Game.tscn")
onready var audio_bus = preload("res://MainMenu/main_menu_mixer.tres")

func _ready():
	AudioServer.set_bus_layout(audio_bus)
	$ambience.play()
	$music.play()

func _on_Play_pressed():
	get_tree().change_scene_to(claw_game)

func _on_Credits_pressed():
	pass # Replace with function body.

func _on_CharacterSelect_pressed():
	pass # Replace with function body.

func _on_Prizes_pressed():
	pass # Replace with function body.
