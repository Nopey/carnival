extends Node

onready var claw_game = preload("res://Claw/Game.tscn")

func _on_Play_pressed():
	get_tree().change_scene_to(claw_game)

func _on_Credits_pressed():
	pass # Replace with function body.

func _on_CharacterSelect_pressed():
	pass # Replace with function body.

func _on_Prizes_pressed():
	pass # Replace with function body.
