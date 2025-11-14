class_name Room
extends Node3D

#region Room_State_Parameters
##Coordinate of the room on the generated 2d map.
var coords : Vector2i
##Reference to the current world.
var world : World
##Boolean indicating if the player is in this room.
var is_active : bool = false
##Boolean indicating if every enemies have been killed.
var is_cleared : bool = false
#endregion

#region Enemy_Handling_Parameters
var enemy_spawners = []
var enemies : Array[Enemy] = []
var enemies_defeated = 0
static var enemy_melee_scene : PackedScene = preload("res://scenes/rooms/elements/enemies/enemy_melee.tscn")
static var enemy_ranged_scene : PackedScene = preload("res://scenes/rooms/elements/enemies/ranged_enemy.tscn")
static var enemy_tentacle_scene : PackedScene = preload("res://scenes/rooms/elements/enemies/boss_tentacle_enemy.tscn")
#endregion

#region Room_Population_Parameters
var orb_position : Vector3
#endregion

#region Children_References
##Position of the camera
@onready var camera_position : Vector3 = $Camera_pos.global_position
##Navigation region
@onready var nav : NavigationRegion3D = $NavigationRegion3D
##Up door CSGBox
@onready var doorUp : CSGBox3D = $NavigationRegion3D/Door_up
##Down door CSGBox
@onready var doorDown : CSGBox3D = $NavigationRegion3D/Door_down
##Left door CSGBox
@onready var doorLeft : CSGBox3D = $NavigationRegion3D/Door_left
##Right door CSGBox
@onready var doorRight : CSGBox3D = $NavigationRegion3D/Door_right
##Up door mat CSGBox
@onready var doorMatUp : CSGBox3D = $NavigationRegion3D/Doormat_up
##Down door mat CSGBox
@onready var doorMatDown : CSGBox3D = $NavigationRegion3D/Doormat_down
##Left door mat CSGBox
@onready var doorMatLeft : CSGBox3D = $NavigationRegion3D/Doormat_left
##Right door mat CSGBox
@onready var doorMatRight : CSGBox3D = $NavigationRegion3D/Doormat_right

@onready var ground : CSGBox3D = $NavigationRegion3D/Ground
@onready var wall_left : CSGBox3D = $NavigationRegion3D/Wall_left
@onready var wall_left2 : CSGBox3D = $NavigationRegion3D/Wall_left2
@onready var wall_right : CSGBox3D = $NavigationRegion3D/Wall_right
@onready var wall_right2 : CSGBox3D = $NavigationRegion3D/Wall_right2
@onready var wall_up : CSGBox3D = $NavigationRegion3D/Wall_up
@onready var wall_up2 : CSGBox3D = $NavigationRegion3D/Wall_up2
@onready var wall_down : CSGBox3D = $NavigationRegion3D/Wall_down
@onready var wall_down2 : CSGBox3D = $NavigationRegion3D/Wall_down2

@onready var camera_trigger : CollisionShape3D = $Camera_pos/Camera_zone/CollisionShape3D
#endregion

func _ready():
	self.visible = false
	

func resize(x:float,z:float):
	ground.size.x = x
	ground.size.z = z
	wall_left.size.x = (x - 3.0) / 2.0
	wall_left.position.x = (wall_left.size.x / 2.0) + 1.5
	wall_left.position.z = z / 2.0
	wall_left2.size.x = (x - 3.0) / 2.0
	wall_left2.position.x = -((wall_left.size.x / 2.0) + 1.5)
	wall_left2.position.z = z / 2.0
	
	wall_right.size.x = (x - 3.0) / 2.0
	wall_right.position.x = (wall_left.size.x / 2.0) + 1.5
	wall_right.position.z = -z / 2.0
	wall_right2.size.x = (x - 3.0) / 2.0
	wall_right2.position.x = -((wall_left.size.x / 2.0) + 1.5)
	wall_right2.position.z = -z / 2.0
	
	wall_up.size.z = (z - 3.0) / 2.0
	wall_up.position.z = (wall_up.size.z / 2.0) + 1.5
	wall_up.position.x = -x / 2.0
	wall_up2.size.z = (z - 3.0) / 2.0
	wall_up2.position.z = -((wall_up.size.z / 2.0) + 1.5)
	wall_up2.position.x = -x / 2.0
	
	wall_down.size.z = (z - 3.0) / 2.0
	wall_down.position.z = (wall_up.size.z / 2.0) + 1.5
	wall_down.position.x = x / 2.0
	wall_down2.size.z = (z - 3.0) / 2.0
	wall_down2.position.z = -((wall_up.size.z / 2.0) + 1.5)
	wall_down2.position.x = x / 2.0
	
	doorUp.position.x = wall_up.position.x
	doorDown.position.x = wall_down.position.x
	doorLeft.position.z = wall_left.position.z
	doorRight.position.z = wall_right.position.z
	
	doorMatUp.position.x = wall_up.position.x
	doorMatDown.position.x = wall_down.position.x
	doorMatLeft.position.z = wall_left.position.z
	doorMatRight.position.z = wall_right.position.z
	
	camera_trigger.shape.size = Vector3(x,25,z)

func set_world(_world : World):
	self.world = _world

func spawn_enemies():
	if self.is_cleared: return
	if not world.boss_world and world.start_room.coords == coords: return
	for enemy_spawner in enemy_spawners as Array[EnemySpawner]:
		var enemy : Enemy
		if enemy_spawner.enemyType == 1:
			enemy = spawn_enemy_ranged()
		if enemy_spawner.enemyType == 3:
			enemy = spawn_enemy_melee()
		if enemy_spawner.enemyType == 2:
			enemy = spawn_enemy_tentacle()
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

func spawn_enemy_tentacle() -> Enemy:
	var enemy_tentacle : Enemy = enemy_tentacle_scene.instantiate()
	return enemy_tentacle

func init_enemy(enemy : Enemy, enemy_spawner : EnemySpawner):
	enemy.position = enemy_spawner.position
	enemy.set_spawn( self.global_position + enemy_spawner.position )
	enemy.room = self
	enemy.player = world.player
	enemy.dead.connect(on_enemy_dies)

func activate_room():
	is_active = true
	self.visible = true
	for o in nav.get_children():
		o.use_collision = true
	spawn_enemies()

func deactivate_room():
	is_active = false
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


#region Generation_Methods
##Open the wall between this room and room of coordinates _coords.
func open_wall(_coords : Vector2i):
	if self.coords[0] == _coords[0]:
		if self.coords[1]+1 == _coords[1]:
			doorLeft.visible = false
			doorMatLeft.visible = true
			doorLeft.set_collision_layer_value(1,false)
		elif self.coords[1]-1 == _coords[1]:
			doorRight.visible = false
			doorMatRight.visible = true
			doorRight.set_collision_layer_value(1,false)
	elif self.coords[1] == _coords[1]:
		if self.coords[0]-1 == _coords[0]:
			doorUp.visible = false
			doorMatUp.visible = true
			doorUp.set_collision_layer_value(1,false)
		elif self.coords[0]+1 == _coords[0]:
			doorDown.visible = false
			doorMatDown.visible = true
			doorDown.set_collision_layer_value(1,false)

##Integrate layout to the room.
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
#endregion
