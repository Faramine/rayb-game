extends Area3D

var player_is_in = false

func _ready() -> void:
	self.area_entered.connect(_on_entered)
	self.area_exited.connect(_on_exited)

func _on_entered(area : Area3D):
	if area and area.is_in_group("Player"):
		player_is_in = true

func _on_exited(area : Area3D):
	if area and area.is_in_group("Player"):
		player_is_in = false
