class_name Main
extends Node2D

var speed:float = 0.1
var spawnrate: float = 0.4
var damage:float = 1
var difficulty:float = 1
var difficulty_scale: float = 0.02
var fire_rate:float = 1
var last_fire:float = 0
var projectile_speed:float = 1
var multiplier: int = 1
var game_speed: float = 0.4

var health:float = 10;
var max_health:float = 10;
var base_points: float = 0;

@onready
var player = $"The Grid/Player"

@onready
var grid = $"The Grid";

@onready
var enemy:PackedScene = load("res://enemy.tscn");

@onready
var shot:PackedScene = load("res://gun.tscn");

@onready
var point:PackedScene = load("res://point.tscn");

@onready
var maxhp = $HPPanel
@onready
var hp =$HPPanel/HP
@onready
var hptext = $HPPanel/HPText

@onready
var basepointstext = $PointsPanel/PointsText
@onready
var basepointspanel = $PointsPanel
@onready
var basepoints = $PointsPanel/Points

func _ready() -> void:
	maxhp.visible = false
	basepointspanel.visible = false

func move_player(delta:float) -> void:
	player.position.y -= game_speed*delta;
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
	e.main = self
	grid.add_child(e);
	
func fire() -> void:
	var e:Shot = shot.instantiate();
	e.position = player.position;
	e.position.y-=0.02;
	e.show_behind_parent = player.show_behind_parent;
	e.scale=Vector2(0.002, 0.002);
	e.target=null
	e.speed*=projectile_speed+game_speed
	grid.add_child(e);

func spawn_point(position: Vector2, behind_parent: bool, count: int, value: float=1):
	for i: int in range(count*multiplier):
		var offset=Vector2(randf()*0.005*count - 0.0025*count, randf()*0.005*count - 0.0025*count)
		var p:PointScore = point.instantiate()
		p.position = position
		p.position+=offset;
		p.show_behind_parent = behind_parent
		p.scale=Vector2(0.01, 0.01);
		p.speed*=game_speed
		p.value*=value
		p.collision_layer = 8 if behind_parent else 4
		grid.add_child(p)
		

func _physics_process(delta:float):
	move_player(delta)

func _process(delta: float) -> void:
	game_speed *= 1+0.01*delta;
	difficulty+=difficulty_scale*delta;
	basepoints.rotation += 0.4*delta
	check_spawn(delta)
	check_fire(delta)

func _on_player_area_entered(area: Area2D) -> void:
	if area is Enemy: 
		var e = area as Enemy
		health-=e.hp
		updateHP()
		e.queue_free();
	elif area is PointScore:
		var p = area as PointScore
		base_points += p.value
		updatePoints()
		p.queue_free()
		
func updateHP() -> void:
	maxhp.visible = true;
	maxhp.size.x = clamp(130+max_health, 140, 440)
	hptext.size.x = maxhp.size.x
	hp.size.x = health / max_health * maxhp.size.x
	hptext.text = "%.1f/%.1f" % [health, max_health]
	
func updatePoints() -> void:
	basepointspanel.visible = true;
	basepointstext.text = "%d" % [base_points]
