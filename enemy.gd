extends Area2D

@export
var speed: Vector2 = Vector2(randf()*0.02-0.01, randf()*0.2-0.1);

func _physics_process(delta:float):
	position+=speed*delta;
	if position.y < 0:
		position.y+=1.053;
		show_behind_parent = !show_behind_parent;		
	if position.x < 0.75:
		position.x = 0.75;
	if position.x > 1.17:
		position.x = 1.17;
	if (position.y > 1.06):
		position.y=0;
	pass;
