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
var multiplier: int = 100
var game_speed: float = 0.4
var health_regen: float = 0
var green_multiplier: int = 0
var armor: float = 1
var laser_count:int = 0
var laser_reach:float = 1
var multishot:int = 1
var explosion_size:float = 0
var boss_spawn_rate:float = 0
var laserExplosion:int = 0
var lifes:int =0
var vampiric:float = 0

var health:float = 10;
var max_health:float = 10;
var base_points: float = 40000;
var green_points: float = 20000;

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
var greenpoint:PackedScene = load("res://green_point.tscn");

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

@onready
var greenpointstext = $GreenPoints/PointsText
@onready
var greenpointspanel = $GreenPoints
@onready
var greenpoints = $GreenPoints/Points

@onready
var upgrades = $Upgrades

@onready
var startButton = $StartButton

@onready
var UpgradeLabel = $Panel/Label

@onready
var UpgradePanel = $Panel


var running = true;

func _ready() -> void:
	maxhp.visible = false
	basepointspanel.visible = false
	greenpointspanel.visible = false
	UpgradePanel.visible = false
	startButton.visible = false

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

func check_spawn(delta:float) -> void:
	if randf() < (spawnrate*(0.6+game_speed))*delta:
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
	grid.call_deferred("add_child", e)
	
func fire() -> void:
	var e:Shot = shot.instantiate();
	e.position = player.position;
	e.position.y-=0.02;
	e.show_behind_parent = player.show_behind_parent;
	e.scale=Vector2(0.002, 0.002);
	e.target=null
	e.speed*=projectile_speed
	e.speed-=Vector2(0, game_speed)
	grid.call_deferred("add_child", e)

func spawn_point(pos: Vector2, behind_parent: bool, count: int, value: int):
	for i: int in range(count*multiplier):
		var offset=Vector2(randf()*0.05*count - 0.025*count, randf()*0.05*count - 0.025*count)
		var p:PointScore = point.instantiate()
		p.position = pos
		p.position+=offset;
		p.show_behind_parent = behind_parent
		p.scale=Vector2(0.01, 0.01);
		p.speed*=game_speed
		p.value*=value
		p.collision_layer = 8 if behind_parent else 4
		grid.call_deferred("add_child", p)
	if green_multiplier > 0 && randf()<0.05:
		spawn_green(pos, behind_parent, 1, value)

func spawn_green(pos: Vector2, behind_parent: bool, count: int, value: float=1):
	for i: int in range(count*green_multiplier):
		var offset=Vector2(randf()*0.05*count - 0.025*count, randf()*0.05*count - 0.025*count)
		var p:GreenScore = greenpoint.instantiate()
		p.position = pos
		p.position+=offset;
		p.show_behind_parent = behind_parent
		p.scale=Vector2(0.01, 0.01);
		p.speed*=game_speed
		p.value*=value
		p.collision_layer = 8 if behind_parent else 4
		grid.call_deferred("add_child", p)
		

func _physics_process(delta:float):
	if running:
		move_player(delta)
		health=clampf(health+max_health*health_regen*delta, -1, max_health)

func _process(delta: float) -> void:
	if running:
		if (Input.is_action_pressed("ui_cancel")):
			stop();
		game_speed *= 1+0.01*delta;
		difficulty+=difficulty_scale*delta;
		basepoints.rotation += 0.4*delta
		check_spawn(delta)
		check_fire(delta)
	else:
		if (Input.is_action_pressed("ui_cancel")):
			startButton.grab_focus()

func _on_player_area_entered(area: Area2D) -> void:
	if running:
		if area is Enemy: 
			var e = area as Enemy
			health-=e.hp*armor
			updateHP()
			e.queue_free();
		elif area is PointScore:
			var p = area as PointScore
			base_points += p.value
			updatePoints()
			checkUpgrades()
			p.queue_free()
		elif area is GreenScore:
			var p = area as GreenScore
			green_points += p.value
			updateGreenPoints()
			checkUpgrades()
			p.queue_free()
		
func updateHP() -> void:
	if health < 0:
		if lifes <= 0:
			stop()
		else:
			lifes-=1
			health = max_health
	maxhp.visible = true;
	maxhp.size.x = clamp(130+max_health, 140, 440)
	hptext.size.x = maxhp.size.x
	hp.size.x = health / max_health * maxhp.size.x
	hptext.text = "%.1f/%.1f" % [health, max_health]
	
func updatePoints() -> void:
	basepointspanel.visible = true;
	UpgradePanel.visible = true;
	basepointstext.text = "%d" % [base_points]
	
func updateGreenPoints() -> void:
	greenpointspanel.visible = true;
	greenpointstext.text = "%d" % [green_points]

func checkUpgrades() -> void:
	for child in upgrades.get_children():
		child.check()
		
func stop() -> void:
	startButton.visible = true
	startButton.grab_focus()
	startButton.release_focus()
	health = 0;
	for child in upgrades.get_children():
		child.run()
	player.visible = false
	running = false;
	checkUpgrades()

func start() -> void:
	apply_upgrades()
	startButton.visible = false
	health = max_health
	running = true
	player.visible = true
	player.position = Vector2(0.96, 1.04)
	for child in upgrades.get_children():
		child.stop()
	for child in grid.get_children():
		if child is Enemy:
			child.queue_free()
	updateAll()

func updateAll()->void:
	updateHP()
	updatePoints()
	if green_multiplier > 0:
		updateGreenPoints()
	checkUpgrades()
	
	
func displayUpgradeText(t: String)->void:
	UpgradeLabel.text = t;

func _on_start_button_pressed() -> void:
	start()

func _on_start_button_mouse_entered() -> void:
	startButton.grab_focus()
	
func apply_upgrades()->void:
	max_health = 10
	speed = 0.1
	spawnrate = 0.4
	damage = 1
	difficulty = 1
	difficulty_scale = 0.02
	fire_rate = 1
	last_fire = 0
	projectile_speed = 1
	multiplier = 1
	game_speed = 0.4
	health_regen = 0
	green_multiplier = 0
	armor = 1
	laser_count = 0
	laser_reach = 1
	multishot = 1
	explosion_size = 0
	boss_spawn_rate = 0
	laserExplosion = 0
	lifes=0;
	vampiric = 0;
	for child in upgrades.get_children():
		child.apply()
	
