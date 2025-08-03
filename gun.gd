class_name Shot
extends Area2D

@export
var speed: Vector2 = Vector2(0, -0.5);

@export
var main:Main = null;

@export
var damage:float = 2;

var swapped = false;


func _physics_process(delta:float):
	position+=speed*delta;
	if position.y < 0:
		position.y+=1.053
		if swapped:
			queue_free()
		else:
			swapped = true
			show_behind_parent = !show_behind_parent
	if position.x < 0.75:
		position.x = 0.75
	if position.x > 1.17:
		position.x = 1.17
	if (position.y > 1.06):
		position.y = 0
		if swapped:
			queue_free()
		else:
			swapped = true
			show_behind_parent = !show_behind_parent
	collision_layer = 0
	collision_mask = 8 if show_behind_parent else 4

func _on_area_entered(area: Area2D) -> void:
	if area is Enemy: 
		var e = area as Enemy
		e.damage(damage)
		if main.laserExplosion > 0:
			main.fire_laser(position, show_behind_parent, main.laserExplosion)
		if main.explosion_size > 0:
			main.spawn_explosion(position, show_behind_parent, main.explosion_size)
		queue_free();
