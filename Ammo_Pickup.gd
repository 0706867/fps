extends Spatial																			#can only be used on a spatial node 

export (int, "full size", "small") var kit_size = 0 setget kit_size_change				#export fucntion lets the developer change the size from the inspector

# 0 = full size pickup, 1 = small pickup
const AMMO_AMOUNTS = [4, 1]																	#ammo amount first entry[0] = 4 which gives 4 magazines and second entry[1] = 1 gives 1 magazine
const RESPAWN_TIME = 20																		#respawn timer for the ammo pickup
var respawn_timer = 0																		#time on the respawn timer
var is_ready = false																		#can it be picked up
const GRENADE_AMOUNTS = [2, 0]																#how many grenades get filled up

func _ready():

	$Holder/Ammo_Pickup_Trigger.connect("body_entered", self, "trigger_body_entered")		#connects the node to the functions, when something collies it enables the trigger body function

	is_ready = true																	# is able to be picked up

	kit_size_change_values(0, false)												#change value to 0(first entry)? no
	kit_size_change_values(1, false)												#change value to 1? (second entry) no

	kit_size_change_values(kit_size, true)											#change the value to the size provided in the inspector? yes


func _physics_process(delta):
	if respawn_timer > 0:															#if timer is higher than 0, remove delta from the timer
		respawn_timer -= delta

		if respawn_timer <= 0:														#if the time lower than 0, spawn the turret
			kit_size_change_values(kit_size, true)


func kit_size_change(value):
	if is_ready:
		kit_size_change_values(kit_size, false)
		kit_size = value

		kit_size_change_values(kit_size, true)
	else:
		kit_size = value


func kit_size_change_values(size, enable):
	if size == 0:
		$Holder/Ammo_Pickup_Trigger/Shape_Kit.disabled = !enable
		$Holder/Ammo_Kit.visible = enable
	elif size == 1:
		$Holder/Ammo_Pickup_Trigger/Shape_Kit_Small.disabled = !enable
		$Holder/Ammo_Kit_Small.visible = enable


func trigger_body_entered(body):
	if body.has_method("add_ammo"):
		body.add_ammo(AMMO_AMOUNTS[kit_size])
		respawn_timer = RESPAWN_TIME
		kit_size_change_values(kit_size, false)

	if body.has_method("add_grenade"):
		body.add_grenade(GRENADE_AMOUNTS[kit_size])
		respawn_timer = RESPAWN_TIME
		kit_size_change_values(kit_size, false)
