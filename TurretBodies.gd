extends StaticBody

export (NodePath) var path_to_turret_root											#gets the path for turret body

func _ready():
	pass

func bullet_hit(damage, bullet_hit_pos):											#if the turret gets hit, and there is a path to the turret body, do damage.
	if path_to_turret_root != null:
		get_node(path_to_turret_root).bullet_hit(damage, bullet_hit_pos)
