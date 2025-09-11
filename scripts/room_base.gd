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
var enemy_dummy_scene : PackedScene = load("res://enemy_dummy.tscn")
@onready var enemies : Array[Enemy] = []

func _ready():
	ceiling.visible = true
	self.visible = false
	if(randi()%2==0): debug_spawn_dummy()
	if(randi()%2==0): debug_spawn_dummy(Vector3(-5,0,-5))
	
func set_world(world : World):
	self.world = world

func debug_spawn_dummy(offset = Vector3.ZERO):
	var enemy_dummy : Enemy = enemy_dummy_scene.instantiate()
	var spawn_pos = $EnemySpawnPoint.global_position
	spawn_pos += offset
	enemy_dummy.global_position = spawn_pos
	enemy_dummy.set_spawn( spawn_pos )
	enemy_dummy.room = self
	enemy_dummy.player = world.player
	enemies.append(enemy_dummy)
	add_child(enemy_dummy)

func activate_room():
	is_active = true
	ceiling.visible = false
	godray.visible = true
	walldown1.material.albedo_color.a = 0.5
	walldown2.material.albedo_color.a = 0.5
	self.visible = true
	for enemy in enemies:
		enemy.on_room_activated()

func deactivate_room():
	is_active = false
	ceiling.visible = true
	godray.visible = false
	walldown1.material.albedo_color.a = 1.0
	walldown2.material.albedo_color.a = 1.0
	self.visible = false
	for enemy in enemies:
		enemy.on_room_deactivated()

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
