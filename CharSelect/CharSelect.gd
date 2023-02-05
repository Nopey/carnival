extends Node2D

onready var Character = Global.Character
func _on_Carrot_pressed():
	Global.character = Character.Carrot
func _on_Potato_pressed():
	Global.character = Character.Potato
func _on_Celeriac_pressed():
	Global.character = Character.Celeriac

func _on_Back_pressed():
	var main_menu = load("res://MainMenu/MainMenu.tscn")
	get_tree().change_scene_to(main_menu)
