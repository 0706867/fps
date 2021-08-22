extends Spatial

func _ready():																		#get the node this script is attached to and set the respawn points in the global script as the current nodes children
	var globals = get_node("/root/Globals")
	globals.respawn_points = get_children()
