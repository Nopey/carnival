extends Sprite

func _process(delta):
	match Global.character:
		Global.Character.Carrot:
			self.position.x = 251
			self.position.y = 662
		Global.Character.Potato:
			self.position.x = 869
			self.position.y = 762
		Global.Character.Celeriac:
			self.position.x = 1552
			self.position.y = 562
