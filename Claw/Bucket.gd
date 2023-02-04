extends Area2D
class_name Bucket

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

export var target: Vector2 = Vector2(600, 400)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for area in get_overlapping_areas():
		if not area is Turnip:
			continue
		var turnip: Turnip = area
		var normal = (target - turnip.global_position).normalized()
		var tangent = normal.tangent()
		if turnip.flee_path.dot(normal) < 0:
			turnip.flee_path = turnip.flee_path.reflect(tangent)
		else:
			turnip.flee_path = lerp(turnip.flee_path, normal, pow(0.5, delta))
