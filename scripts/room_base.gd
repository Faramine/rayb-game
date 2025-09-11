class_name Room
extends Node3D

@onready var camera_posistion : Vector3 = $Camera_pos.global_position
@onready var ceiling : CSGBox3D = $Ceiling
@onready var godray = $GodRay
@onready var walldown1 = $NavigationRegion3D/Wall_down
@onready var walldown2 = $NavigationRegion3D/Wall_down2

var coords = [0,0]
var world : World
var is_active : bool = false

@onready var enemies : Array[Enemy] = [$Enemy]

func _ready():
	ceiling.visible = true
	self.visible = false

func set_world(world : World):
	self.world = world

func activate_room():
	is_active = true
	ceiling.visible = false
	godray.visible = true
	walldown1.material.albedo_color.a = 0.5
	walldown2.material.albedo_color.a = 0.5
	self.visible = true
	print("activate : " + str(coords))

func deactivate_room():
	is_active = false
	ceiling.visible = true
	godray.visible = false
	walldown1.material.albedo_color.a = 1.0
	walldown2.material.albedo_color.a = 1.0
	self.visible = false
	print("deactivate : " + str(coords))

func _process(delta: float) -> void:
	if(is_active):
		for enemy in enemies:
			var distance = enemy.global_position.distance_to(self.world.player.global_position)
			var target_position = self.world.player.global_transform.origin + self.world.player.velocity * distance/30
			enemy.target_position(target_position)
	else:
		for enemy in enemies:
			enemy.back_to_spawnpoint()
