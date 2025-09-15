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
var enemy_dummy_scene : PackedScene = load("res://enemy_melee.tscn")
@onready var enemies : Array[Enemy] = []
var nb_enemies = randi()%3

func _ready():
	ceiling.visible = true
	self.visible = false
	
func set_world(world : World):
	self.world = world

func debug_spawn_dummy(offset = Vector3.ZERO) -> Enemy:
	var enemy_melee : Enemy = enemy_dummy_scene.instantiate()
	var spawn_pos = $EnemySpawnPoint.global_position
	spawn_pos += offset
	enemy_melee.global_position = spawn_pos
	enemy_melee.set_spawn( spawn_pos )
	enemy_melee.room = self
	enemy_melee.player = world.player
	enemies.append(enemy_melee)
	add_child(enemy_melee)
	return enemy_melee

func activate_room():
	is_active = true
	ceiling.visible = false
	godray.visible = true
	walldown1.material.albedo_color.a = 0.5
	walldown2.material.albedo_color.a = 0.5
	self.visible = true
	for i in range(0,nb_enemies):
		var enemy = debug_spawn_dummy(Vector3(-9*i,0,-9*i))
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
		enemy.queue_free()
	enemies = []

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
