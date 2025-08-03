class_name Laser
extends Polygon2D

@export var lifetime: float = 0.4

func _physics_process(delta: float) -> void:
	lifetime -= delta;
	if lifetime < 0:
		queue_free()
