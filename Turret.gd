extends Spatial

export (bool) var use_raycast = false

const TURRET_DAMAGE_BULLET = 20
const TURRET_DAMAGE_RAYCAST = 5

const FLASH_TIME = 0.1
var flash_timer = 0

const FIRE_TIME = 0.2
var fire_timer = 0

var node_turret_head = null
var node_raycast = null
var node_flash_one = null
var node_flash_two = null

var ammo_in_turret = 20
const AMMO_IN_FULL_TURRET = 20
const AMMO_RELOAD_TIME = 4
var ammo_reload_timer = 0

var current_target = null

var is_active = false

const PLAYER_HEIGHT = 3

var smoke_particles

var turret_health = 60
const MAX_TURRET_HEALTH = 60

const DESTROYED_TIME = 20
var destroyed_timer = 0

var bullet_scene = preload("Bullet_Scene.tscn")

var globals 
func _ready():

	$Vision_Area.connect("body_entered", self, "body_entered_vision")
	$Vision_Area.connect("body_exited", self, "body_exited_vision")

	node_turret_head = $Head
	node_raycast = $Head/Ray_Cast
	node_flash_one = $Head/Flash
	node_flash_two = $Head/Flash_2

	node_raycast.add_exception(self)
	node_raycast.add_exception($Base/Static_Body)
	node_raycast.add_exception($Head/Static_Body)
	node_raycast.add_exception($Vision_Area)

	node_flash_one.visible = false
	node_flash_two.visible = false

	smoke_particles = $Smoke
	smoke_particles.emitting = false

	turret_health = MAX_TURRET_HEALTH
	
	globals = get_node("/root/Globals")


func _physics_process(delta):

	if is_active == true:															#if the turret is active, enable flash until timer is 0

		if flash_timer > 0:
			flash_timer -= delta

			if flash_timer <= 0:
				node_flash_one.visible = false
				node_flash_two.visible = false

		if current_target != null:													#if there is a target, look at the player

			node_turret_head.look_at(current_target.global_transform.origin + Vector3(0, PLAYER_HEIGHT, 0), Vector3(0, 1, 0))

			if turret_health > 0:													#if turret is alive 

				if ammo_in_turret > 0:												#if turret has ammo (not reloading)
					if fire_timer > 0:												#if its not shooting
						fire_timer -= delta
					else:															#shoot if its not reloading
						fire_bullet()
				else:
					if ammo_reload_timer > 0:										#if turret is reloading, reduce the reload timer
						ammo_reload_timer -= delta
					else:															#if its not reloading, amake the magazine full
						ammo_in_turret = AMMO_IN_FULL_TURRET

	if turret_health <= 0:															#if turret is dead
		if destroyed_timer > 0:														#if the destroyed timer is not 0, reduce time
			destroyed_timer -= delta
		else:																		#if the destroyed tiemr is 0, heal the turret and stop the smoke particles.
			turret_health = MAX_TURRET_HEALTH
			smoke_particles.emitting = false
	if turret_health >= 0:
		visible = true 


func create_sound(sound_name, position=null):										#using sounds, function required sound name, position is required if used in 3D
	globals.play_sound(sound_name, false, position)									#plays the sound it recieves(sound_name), dont loop the audio (false), set the position of the audio (position)

func fire_bullet():
	if use_raycast == true:														#if raycasting is on, follow the player, if the ray is colliding get the body and if it can take damage, shoot it.
		node_raycast.look_at(current_target.global_transform.origin + Vector3(0, PLAYER_HEIGHT, 0), Vector3(0, 1, 0))

		node_raycast.force_raycast_update()

		if node_raycast.is_colliding():
			var body = node_raycast.get_collider()
			print(body.get_parent().get_name())
			if body.has_method("bullet_hit"):
				body.bullet_hit(TURRET_DAMAGE_RAYCAST, node_raycast.get_collision_point())
		ammo_in_turret -= 1


	else:																			#if ray casting is not on, get the bullet scene and use bullet to shoot
		var clone = bullet_scene.instance()
		var scene_root = get_tree().root.get_children()[0]
		scene_root.add_child(clone)

		clone.global_transform = $Head/Barrel_End.global_transform
		clone.scale = Vector3(10, 10, 10)											#bullet from the turret are bigger to prevent players from walking past them
		clone.BULLET_DAMAGE = TURRET_DAMAGE_BULLET
		clone.BULLET_SPEED = 550													#so the player can not dodge them while walking
		create_sound("Pistol_shot", transform.origin)
		ammo_in_turret -= 1

	node_flash_one.visible = true
	node_flash_two.visible = true

	flash_timer = FLASH_TIME
	fire_timer = FIRE_TIME

	if ammo_in_turret <= 0:															#if there are no bullets left, reload the turret
		ammo_reload_timer = AMMO_RELOAD_TIME


func body_entered_vision(body):														#if player enters the range
	if current_target == null:														#if there is no current target, make the player the new target
		if body is KinematicBody:
			current_target = body
			is_active = true


func body_exited_vision(body):														#if a body (player) exits the range
	if current_target != null:														#if there is a current target
		if body == current_target:													#if player is the current target
			current_target = null													#deactivate the turret
			is_active = false

			flash_timer = 0
			fire_timer = 0
			node_flash_one.visible = false
			node_flash_two.visible = false


func bullet_hit(damage, bullet_hit_pos):										#lower health when the turret takes damage, if the health goes below 0, start smoking and the timer
	turret_health -= damage

	if turret_health <= 0:
		smoke_particles.emitting = true
		destroyed_timer = DESTROYED_TIME

