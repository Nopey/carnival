extends Node

onready var claw_game = preload("res://Claw/Game.tscn")
onready var audio_bus = preload("res://MainMenu/main_menu_mixer.tres")

func _ready():
	AudioServer.set_bus_layout(audio_bus)
	$ambience.play()
	$music.play()

func _on_Play_pressed():
	get_tree().change_scene_to(claw_game)

onready var credits = preload("res://Credits/Credits.tscn")
func _on_Credits_pressed():
	get_tree().change_scene_to(credits)

onready var char_select = preload("res://CharSelect/CharSelect.tscn")
func _on_CharacterSelect_pressed():
	get_tree().change_scene_to(char_select)

onready var prize_shop = preload("res://PrizeShop/PrizeShop.tscn")
func _on_Prizes_pressed():
	get_tree().change_scene_to(prize_shop)
