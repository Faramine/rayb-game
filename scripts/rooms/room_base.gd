class_name Room
extends Node3D

#region Children
@onready var camera_position : Vector3 = $Camera_pos.global_position
@onready var ceiling : CSGBox3D = $Ceiling
@onready var nav = $NavigationRegion3D
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
#endregion

var orb_position

var coords : Vector2i = Vector2i(0,0)
var world : World
var is_active : bool = false
var is_cleared : bool = false

var enemy_spawners = []
var enemy_melee_scene : PackedScene = load("res://scenes/rooms/elements/enemies/enemy_melee.tscn")
var enemy_ranged_scene : PackedScene = load("res://scenes/rooms/elements/enemies/ranged_enemy.tscn")

@onready var enemies : Array[Enemy] = []
var enemies_defeated = 0

func _ready():
	ceiling.visible = true
	self.visible = false
	
func set_world(world : World):
	self.world = world

func spawn_enemies():
	if self.is_cleared: return
	if not world.boss_world and world.start_room.coords == coords: return
	for enemy_spawner in enemy_spawners as Array[EnemySpawner]:
		var enemy : Enemy
		if enemy_spawner.enemyType == 1:
			enemy = spawn_enemy_ranged()
		if enemy_spawner.enemyType == 2:
			enemy = spawn_enemy_melee()
		init_enemy(enemy, enemy_spawner)
		enemies.append(enemy)
		add_child(enemy)
		enemy.on_room_activated()

func spawn_enemy_melee() -> Enemy:
	var enemy_melee : Enemy = enemy_melee_scene.instantiate()
	return enemy_melee
	
func spawn_enemy_ranged() -> Enemy:
	var enemy_ranged : Enemy = enemy_ranged_scene.instantiate()
	return enemy_ranged

func init_enemy(enemy : Enemy, enemy_spawner : EnemySpawner):
	enemy.position = enemy_spawner.position
	enemy.set_spawn( self.global_position + enemy_spawner.position )
	enemy.room = self
	enemy.player = world.player
	enemy.dead.connect(on_enemy_dies)

func activate_room():
	is_active = true
	ceiling.visible = false
	#walldown1.material.albedo_color.a = 0.5
	#walldown2.material.albedo_color.a = 0.5
	self.visible = true
	for o in nav.get_children():
		o.use_collision = true
	spawn_enemies()

func deactivate_room():
	is_active = false
	ceiling.visible = true
	#walldown1.material.albedo_color.a = 1.0
	#walldown2.material.albedo_color.a = 1.0
	self.visible = false
	for enemy in enemies:
		enemy.on_room_deactivated()
		enemy.queue_free()
	for o in nav.get_children():
		o.use_collision = false
	enemies = []
	enemies_defeated = 0

func on_enemy_dies():
	enemies_defeated += 1
	if enemies_defeated == enemies.size():
		self.is_cleared = true

func open_wall(coords : Vector2i):
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

func populate(layout : Room_layout):
	layout.position = self.global_position
	add_child(layout)
	
	layout.remove_child(layout.godrays)
	layout.remove_child(layout.decor)
	layout.remove_child(layout.orb_position)
	layout.remove_child(layout.obstacles)
	layout.remove_child(layout.enemies)
	
	if layout is PrebossRoomLayout:
		layout.remove_child(layout.boss_door)
		add_child(layout.boss_door)
		layout.boss_door.connect_door(world)
	
	add_child(layout.godrays)
	add_child(layout.enemies)
	add_child(layout.decor)
	add_child(layout.orb_position)
	orb_position = layout.orb_position.position
	for o in layout.obstacles.get_children():
		layout.obstacles.remove_child(o)
		nav.add_child(o)
	#nav.bake_navigation_mesh(false)
	enemy_spawners = layout.enemies.get_children()
	layout.enemies.visible = false
	remove_child(layout)
