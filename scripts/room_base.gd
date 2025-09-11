class_name Room
extends Node3D

@onready var camera_posistion : Vector3 = $Camera_pos.global_position
@onready var ceiling : CSGBox3D = $Ceiling
@onready var godray = $GodRay
@onready var walldown1 = $NavigationRegion3D/Wall_down
@onready var walldown2 = $NavigationRegion3D/Wall_down2
@onready var doorUp = $NavigationRegion3D/Door_up
@onready var doorDown = $NavigationRegion3D/Door_down
@onready var doorLeft = $NavigationRegion3D/Door_left
@onready var doorRight = $NavigationRegion3D/Door_right
@onready var doorMatUp = $NavigationRegion3D/Doormat_up
@onready var doorMatDown = $NavigationRegion3D/Doormat_down
@onready var doorMatLeft = $NavigationRegion3D/Doormat_left
@onready var doorMatRight = $NavigationRegion3D/Doormat_right

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

func open_wall(coords : Array):
	if self.coords[0] == coords[0]:
		if self.coords[1]+1 == coords[1]:
			doorLeft.visible = false
			doorMatLeft.visible = true
			doorLeft.set_collision_layer_value(1,false)
		elif self.coords[1]-1 == coords[1]:
			doorRight.visible = false
			doorMatRight.visible = true
			doorRight.set_collision_layer_value(1,false)
	elif self.coords[1] == coords[1]:
		if self.coords[0]-1 == coords[0]:
			doorUp.visible = false
			doorMatUp.visible = true
			doorUp.set_collision_layer_value(1,false)
		elif self.coords[0]+1 == coords[0]:
			doorDown.visible = false
			doorMatDown.visible = true
			doorDown.set_collision_layer_value(1,false)
