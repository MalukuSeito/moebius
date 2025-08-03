class_name Explosion
extends Area2D

@export var lifetime: float = 0.4
@export var damage: float = 1
var done:bool = false;

func _physics_process(delta: float) -> void:
	lifetime -= delta;
	done=true
	if lifetime < 0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if done:
		return
	if area is Enemy: 
		var e = area as Enemy
		e.damage(damage)
