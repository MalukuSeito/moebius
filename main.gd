extends Node2D

var speed:float = 0.1
var spawnrate: float = 0.2;


@onready
var player = $"The Grid/Player"

@onready
var grid = $"The Grid";

@onready
var enemy:PackedScene = load("res://enemy.tscn");

func move_player(delta:float):
	player.position.y -= 0.4*delta;
	player.position+=Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")*clampf(speed, 0.1, 0.4)*delta;
	if player.position.y < 0:
		player.position.y+=1.053;
		player.show_behind_parent = !player.show_behind_parent;		
	if player.position.x < 0.75:
		player.position.x = 0.75;
	if player.position.x > 1.17:
		player.position.x = 1.17;
	pass;

func check_spawn(delta:float):
	if randf() < spawnrate*delta:
		spawn()
		
func spawn():
	var e:Node2D = enemy.instantiate();
	e.position = player.position;
	e.show_behind_parent = !player.show_behind_parent;
	e.scale=Vector2(0.01, 0.01);
	grid.add_child(e);
	
	

func _physics_process(delta:float):
	move_player(delta)
	check_spawn(delta)
