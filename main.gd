extends Node2D

@onready
var player = $"The Grid/Player"

func _physics_process(delta):
	player.position.y -= 0.3*delta;
	if (player.position.y < 0):
		player.position.y+=1.053;
		player.show_behind_parent = !player.show_behind_parent;
	pass;
