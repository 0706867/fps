extends Spatial

const DAMAGE = 40
const CAN_RELOAD = false
const CAN_REFILL = false
const RELOADING_ANIM_NAME = ""
const IDLE_ANIM_NAME = "Knife_idle"
const FIRE_ANIM_NAME = "Knife_fire"
var ammo_in_weapon = 1
var spare_ammo = 1
const AMMO_IN_MAG = 1
var is_weapon_enabled = false

var player_node = null

func _ready():
	pass

func fire_weapon(position):
	var area = $Area
	var bodies = area.get_overlapping_bodies()

	for body in bodies:																#if collided area is player, continue (we use continue as we want the loop to continue for each body)
		if body == player_node:
			continue

		if body.has_method("bullet_hit"):											#if the collided body has bullet hit method, do damage
			body.bullet_hit(DAMAGE, area.global_transform)

func equip_weapon():
	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:				#if current stage is idle, set the variable weapon is equipped to true
		is_weapon_enabled = true
		return true

	if player_node.animation_manager.current_state == "Idle_unarmed":				#if the current animation is called "idle_unarmed", set the "knife_unequip" to current animation
		player_node.animation_manager.set_animation("Knife_equip")

	return false

func unequip_weapon():

	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:				#if the current stage is idle, change the animation to "knife_unequip"
		player_node.animation_manager.set_animation("Knife_unequip")

	if player_node.animation_manager.current_state == "Idle_unarmed":				#if current animation is "idle_unarmed", unequip the current weapon
		is_weapon_enabled = false
		return true

	return false

func reload_weapon():
	return false																	#return false as knife can not be reloaded 

func reset_weapon():																#ammo and magazine is being set to 1 so the weapon stays usuable and the code is consistent
	ammo_in_weapon = 1
	spare_ammo = 1
