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
var laser_count:int = 2
var laser_reach:float = 1
var multishot:int = 3
var explosion_size:float = 1
var boss_spawn_rate:float = 0.5
var laserExplosion:int = 0
var lifes:int =0
var vampiric:float = 0.1
var last_laser:float = 0
var max_spawn = 0


var health:float = 10;
var max_health:float = 10;
var base_points: float = 40000;
var green_points: float = 40000;

@onready
var player = $"The Grid/Player"

@onready
var grid = $"The Grid";

@onready
var enemy:PackedScene = load("res://enemy.tscn");

@onready
var boss:PackedScene = load("res://boss.tscn");

@onready
var shot:PackedScene = load("res://gun.tscn");

@onready
var explosion:PackedScene = load("res://explosion.tscn");

@onready
var point:PackedScene = load("res://point.tscn");

@onready
var greenpoint:PackedScene = load("res://green_point.tscn");

@onready
var laser:PackedScene = load("res://laser.tscn");

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
var levelpanel = $LevelPanel
@onready
var level = $LevelPanel/SpinBox

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

@onready
var infopanel = $Panel2
@onready
var infolabel = $Panel2/Label


var running = true;

func _ready() -> void:
	maxhp.visible = false
	basepointspanel.visible = false
	greenpointspanel.visible = false
	UpgradePanel.visible = false
	startButton.visible = false
	levelpanel.visible = false
	infopanel.visible = false
	apply_upgrades()

func move_player(delta:float) -> void:
	player.position.y -= game_speed*delta;
	player.position+=Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")*clampf(speed, 0.1, game_speed)*delta;
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
		if (randf() < boss_spawn_rate):
			spawn_boss()
		else:
			spawn()

func check_fire(delta:float) -> void:
	if last_fire > 0:
		last_fire-=delta;
	if (Input.is_action_pressed("ui_accept")):
		if last_fire <= 0:
			fire();
			last_fire=fire_rate;
			
func check_laser(delta:float) -> void:
	if last_laser > 0:
		last_laser-=delta;
	if last_laser <= 0:
		if fire_laser(player.position, player.show_behind_parent, laser_count):
			last_laser=fire_rate*2;

func sort_by_distance(a:Array,b:Array)-> bool:
	if a[1] < b[1]:
		return true
	return false
	
func spawn_explosion(pos: Vector2, behind:bool, esize:float) -> void:
	var l:Explosion = explosion.instantiate();
	l.position = pos
	l.collision_layer = 0
	l.collision_mask = 8 if behind else 4
	l.scale = Vector2(0.01,0.01)*esize
	l.show_behind_parent = behind
	grid.call_deferred("add_child", l)

func fire_laser(pos: Vector2, behind:bool, lc:int) -> bool:
	var a:Array = []
	var r:float = 0.05*0.05*laser_reach*laser_reach
	for child in grid.get_children():
		if child is Enemy:
			var e:Enemy = child as Enemy
			if e.show_behind_parent == behind:
				var d=e.position.distance_squared_to(pos)
				if d<r:
					a.push_back([e, d])
	a.sort_custom(sort_by_distance)
	if a.is_empty():
		return false
	var s=a.size()
	for i in range(lc):
		var e:Enemy = a[i%s][0] as Enemy
		e.damage(damage)
		var l:Laser = laser.instantiate();
		l.position = pos + Vector2(randf()*0.03-0.015, randf()*0.03-0.015) + (e.position-pos)/2
		l.rotation = pos.angle_to_point(e.position)
		l.scale = Vector2(0.4*pos.distance_to(e.position), 0.002)
		l.show_behind_parent = behind
		grid.call_deferred("add_child", l)
	
	return true

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
	e.hp*=difficulty*level.value
	e.main = self
	grid.call_deferred("add_child", e)
	
func spawn_boss() -> void:
	var e:Boss = boss.instantiate();
	var offset = Vector2(randf()*0.1-0.05, 0);
	e.position = player.position+offset;
	e.speed = Vector2(offset.x*0.25, -game_speed)
	e.show_behind_parent = !player.show_behind_parent
	e.collision_mask = player.collision_layer
	e.collision_layer = player.collision_mask
	e.scale=Vector2(0.01, 0.01);
	e.target=player;
	e.hp*=difficulty*level.value
	e.main = self
	grid.call_deferred("add_child", e)

func spawn_projectile(offset:float) -> void:
	var e:Shot = shot.instantiate();
	e.position = player.position;
	e.position.y-=0.02;
	e.show_behind_parent = player.show_behind_parent;
	e.scale=Vector2(0.002, 0.002);
	e.main = self
	e.speed*=projectile_speed
	e.speed-=Vector2(0, game_speed)
	e.speed.x+=offset
	grid.call_deferred("add_child", e)

func vamp(d:float)->void:
	health+=clampf(d*vampiric, 0, max_health)
	

func fire() -> void:
	spawn_projectile(0)
	for i in range(multishot):
		spawn_projectile((i+1.0)/multishot*0.1)
		spawn_projectile((i+1.0)/multishot*-0.1)

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
		updateHP()

func _process(delta: float) -> void:
	if running:
		if (Input.is_action_pressed("ui_cancel")):
			stop();
		game_speed *= 1+0.01*delta;
		difficulty+=difficulty_scale*delta;
		basepoints.rotation += 0.4*delta
		check_spawn(delta)
		check_fire(delta)
		check_laser(delta)
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
	if health < max_health:
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
	for child in upgrades.get_children():
		child.run()
	for child in grid.get_children():
		if child != player:
			child.queue_free()
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
	apply_upgrades()
	updateLevel()
	updateInfo()
	
func updateLevel()->void:
	if (max_spawn > 0):
		level.max_value = max_spawn + 1
		levelpanel.visible = true

func updateInfo() -> void:
	var lines = []
	if speed > 0.1:
		lines.push_back("Thrusters: %.1f%%" % (speed*100))
	if spawnrate > 0.4:
		lines.push_back("Spawnrate: %.1f%%" % (spawnrate*100))
	if damage > 1:
		lines.push_back("Damage: %.1f" % damage)
	if fire_rate < 1:
		lines.push_back("Fire-Rate %.1f%%" % (1/fire_rate*100))
	if projectile_speed > 1:
		lines.push_back("Projectile Speed: %.1f%%" % (projectile_speed*100))
	if multiplier > 1:
		lines.push_back("Salvage Multiplier: %d" % multiplier)
	if green_multiplier > 1:
		lines.push_back("Coin Multiplier: %d" % green_multiplier)
	if health_regen > 0:
		lines.push_back("Health Regen: %.1f%%" % (health_regen*100))
	if armor < 1:
		lines.push_back("Armor: %.1f%%" % (1/armor*100))
	if laser_count > 0:
		lines.push_back("Lasers: %d" % laser_count)
	if laser_reach > 1:
		lines.push_back("Bonus Laser Distance: %d" % ((laser_reach-1)*100))
	if multishot > 0:
		lines.push_back("Gun Turrets: %d" % (multishot*2+1))
	if explosion_size > 0:
		lines.push_back("Gun Explosion: %.1f%%" % (explosion_size*100))
	if boss_spawn_rate > 0:
		lines.push_back("Boss Chance: %.1f%%" % (boss_spawn_rate*100))
	if laserExplosion > 0:
		lines.push_back("Impact Lasers: %d" % laserExplosion)
	if lifes > 0:
		lines.push_back("Extra Lifes: %d" % lifes)
	if vampiric > 0:
		lines.push_back("Heal on Hit: %.1f%%" % (vampiric*100))
	if !lines.is_empty():
		infopanel.visible = true
		infopanel.size.y = lines.size()*26+2
		infolabel.size.y = lines.size()*26
		infolabel.text = "\n".join(PackedStringArray(lines))

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
	multishot = 0
	explosion_size = 0
	boss_spawn_rate = 0
	laserExplosion = 0
	lifes=0;
	vampiric = 0;
	max_spawn = 0;
	for child in upgrades.get_children():
		child.apply()
	
