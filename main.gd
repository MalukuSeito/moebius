extends Node2D

var speed:float = 0.1
var spawnrate: float = 0.4;
var damage:float = 1;
var difficulty:float = 1;
var difficulty_scale: float = 0.02;
var fire_rate:float = 1;
var last_fire:float = 0;
var projectile_speed:float = 1;

var health = 10;

@onready
var player = $"The Grid/Player"

@onready
var grid = $"The Grid";

@onready
var enemy:PackedScene = load("res://enemy.tscn");

@onready
var shot:PackedScene = load("res://gun.tscn");

func move_player(delta:float) -> void:
	player.position.y -= 0.4*delta;
	player.position+=Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")*clampf(speed, 0.1, 0.4)*delta;
	if player.position.y < 0:
		player.position.y += 1.053
		player.show_behind_parent = !player.show_behind_parent;		
	if player.position.x < 0.75:
		player.position.x = 0.75
	if player.position.x > 1.17:
		player.position.x = 1.17
	player.collision_layer = 2 if player.show_behind_parent else 1
	player.collision_mask = 8 if player.show_behind_parent else 4
	pass;

func check_spawn(delta:float) -> void:
	if randf() < spawnrate*delta:
		spawn()

func check_fire(delta:float) -> void:
	if last_fire > 0:
		last_fire-=delta;
	if (Input.is_action_pressed("ui_accept")):
		if last_fire <= 0:
			fire();
			last_fire=fire_rate;

func spawn() -> void:
	var e:Enemy = enemy.instantiate();
	var offset = Vector2(randf()*0.1-0.05, 0);
	e.position = player.position+offset;
	e.speed+=-offset*0.25;
	e.show_behind_parent = !player.show_behind_parent
	e.collision_mask = player.collision_layer
	e.collision_layer = player.collision_mask
	e.scale=Vector2(0.01, 0.01);
	e.target=player;
	e.hp*=difficulty;
	grid.add_child(e);
	
func fire() -> void:
	var e:Shot = shot.instantiate();
	e.position = player.position;
	e.position.y-=0.02;
	e.show_behind_parent = player.show_behind_parent;
	e.scale=Vector2(0.002, 0.002);
	e.target=null
	e.speed*=projectile_speed
	grid.add_child(e);

func _physics_process(delta:float):
	move_player(delta)

func _process(delta: float) -> void:
	difficulty+=difficulty_scale*delta;
	check_spawn(delta)
	check_fire(delta)

func _on_player_area_entered(area: Area2D) -> void:
	if area is Enemy: 
		var e = area as Enemy
		health-=e.hp
		e.queue_free();
		
