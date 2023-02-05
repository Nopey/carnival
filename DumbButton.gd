extends Area2D

signal pressed

onready var sprite: Texture = $Sprite.texture
export var hover_sprite: Texture

func _on_hover_start():
	if hover_sprite:
		$Sprite.texture = hover_sprite
func _on_hover_end():
	$Sprite.texture = sprite

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		emit_signal("pressed")
