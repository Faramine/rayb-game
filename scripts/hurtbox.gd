class_name HurtBox
extends Area3D

func _ready() -> void:
	connect("area_entered", self._on_area_entered)

func _on_area_entered(hitbox: Area3D) -> void:
	if hitbox == null or not (hitbox is HitBox): return
	print("td",hitbox.owner)
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox)
