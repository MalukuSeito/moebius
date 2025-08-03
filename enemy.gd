class_name Enemy
extends Area2D

@export
var speed: Vector2 = Vector2(randf()*0.02-0.01, randf()*0.2-0.1);

@export
var main: Main

@export
var target:Node2D = null;

@export
var hp:float = 1;
var max_hp:float = 0;

func _physics_process(delta:float):
	position+=speed*delta;
	if position.y < 0:
		position.y+=1.053
		show_behind_parent = !show_behind_parent;
		collision_layer = 8 if show_behind_parent else 4
		collision_mask = 0
	if position.x < 0.75:
		position.x = 0.75
	if position.x > 1.17:
		position.x = 1.17
	if (position.y > 1.06):
		position.y = 0
		show_behind_parent = !show_behind_parent;
	collision_layer = 8 if show_behind_parent else 4
	collision_mask = 0
	
func damage(d:float)->float:
	if hp <= 0:
		return -d;
	if max_hp <= 0:
		max_hp = hp;
	hp-=d
	if main.vampiric > 0:
		main.vamp(d)
	if hp <= 0:
		queue_free()
		if main != null:
			var val:float = clampf((log(max_hp)), 1, 100) 
			main.spawn_point(position, show_behind_parent, 1, int(val))
		return -hp
	else:
		var off = 0.5+0.5*hp/max_hp
		modulate = Color(off, off, off)
		return 0
