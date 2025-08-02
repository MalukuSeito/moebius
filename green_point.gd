class_name GreenScore
extends Area2D

@export
var speed: Vector2 = Vector2(0, 0.2);

@export
var value:float = 1;

var swapped = false;

var origscale:Vector2 = Vector2(0,0);


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
	collision_layer = 8 if show_behind_parent else 4
	collision_mask = 0
	if origscale.x==0:
		origscale.x = scale.x;
		origscale.y = scale.y;
	scale = Vector2(sin(Time.get_ticks_msec()*0.011)*0.001, 0)+origscale
