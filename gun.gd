class_name Shot
extends Area2D

@export
var speed: Vector2 = Vector2(0, -0.6);

@export
var target:Node2D = null;

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
	collision_layer = 2 if show_behind_parent else 1
	collision_mask =  8 if show_behind_parent else 4
	pass;

func _on_area_entered(area: Area2D) -> void:
	if area is Enemy: 
		var e = area as Enemy
		e.hp-=damage
		if e.hp <= 0:
			e.queue_free()
		queue_free();
