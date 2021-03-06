extends Spatial

const DAMAGE = 10
var ammo_in_weapon = 10
var spare_ammo = 50
const AMMO_IN_MAG = 14
const IDLE_ANIM_NAME = "Pistol_idle"
const FIRE_ANIM_NAME = "Pistol_fire"
const CAN_RELOAD = true
const CAN_REFILL = true
const RELOADING_ANIM_NAME = "Pistol_reload"
var is_weapon_enabled = false

var bullet_scene = preload("Bullet_Scene.tscn")

var player_node = null

func _ready():
	pass

func fire_weapon(position):																	#the weapon is using projectiles so every bullet needs to be instanced separately to be tracked.
	var clone = bullet_scene.instance()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(clone)
	player_node.create_sound("Pistol_shot", position)

#sets the location, size, damage, ammo size and the sound of the bullet
	clone.global_transform = self.global_transform
	clone.scale = Vector3(4, 4, 4)
	clone.BULLET_DAMAGE = DAMAGE 
	ammo_in_weapon -= 1


func equip_weapon():
	#similar to knife animation, using pistol animations
	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
		is_weapon_enabled = true
		return true

	if player_node.animation_manager.current_state == "Idle_unarmed":
		player_node.animation_manager.set_animation("Pistol_equip")

	return false

func unequip_weapon():
	#also similar to knfie animation.
	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
		if player_node.animation_manager.current_state != "Pistol_unequip":
			player_node.animation_manager.set_animation("Pistol_unequip")

	if player_node.animation_manager.current_state == "Idle_unarmed":
		is_weapon_enabled = false
		return true
	else:
		return false

func reload_weapon():
	var can_reload = false															#weapon can not be reloaded by default as magazine is full

	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:				#if the weapon is in idle stage, it can reload
		can_reload = true

	if spare_ammo <= 0 or ammo_in_weapon == AMMO_IN_MAG:							#if there is no spare ammo or the ammo in weapon and magazine is the same, presumably 0, pistol can not reload
		can_reload = false

	if can_reload == true:															#if pistol can reload, set ammo_needed to, extra ammo - current ammo
		var ammo_needed = AMMO_IN_MAG - ammo_in_weapon

		if spare_ammo >= ammo_needed:												#if ammo in mag is higher than the needed amount, subtract the needed amount from total ammo
			spare_ammo -= ammo_needed
			ammo_in_weapon = AMMO_IN_MAG
		else:																		#if ammo in mag is not higher than needed, add ammo in mag to current ammo. and set ammo in mag to 0
			ammo_in_weapon += spare_ammo
			spare_ammo = 0

		player_node.animation_manager.set_animation(RELOADING_ANIM_NAME)			#change animation and play audio.
		player_node.create_sound("Gun_cock", player_node.camera.global_transform.origin)
		return true

	return false

func reset_weapon():																#reset weapon ammo and magazine ammo, these provide the default ammo for the weapon
	ammo_in_weapon = 10
	spare_ammo = 20
