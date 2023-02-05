extends Node2D

func _on_Back_pressed():
	var main_menu = load("res://MainMenu/MainMenu.tscn")
	get_tree().change_scene_to(main_menu)
