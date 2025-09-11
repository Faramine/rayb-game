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
	add_child(enemy_dummy)
	var spawn_pos = $EnemySpawnPoint.global_position
	spawn_pos += offset
	enemy_dummy.global_position = spawn_pos
	enemy_dummy.set_spawn( spawn_pos )
	enemy_dummy.player = world.player
	enemies.append(enemy_dummy)

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
