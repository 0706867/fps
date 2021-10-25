extends Label

func _process(delta):
	set_text("Score : " + str(Globals.score))
