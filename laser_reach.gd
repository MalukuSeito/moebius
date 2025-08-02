class_name LaserReach
extends Upgrade

@export var bonus:float = 0.5

@export var base_point_cost:int = 25
@export var cost_scale:float = 10

func apply() -> void:
	main.laser_reach += bonus*count

func pay() -> void:
	main.green_points -= base_point_cost+count*base_point_cost*cost_scale

func cost() -> String:
	return "%d Laser Coins" % (base_point_cost+count*base_point_cost*cost_scale)
	
func valueFormatted(c: int)->String:
	return "Lasers have %d%% more range" % (bonus*c/100)

func avail() -> bool:
	return dependendable() && base_point_cost + count * base_point_cost * cost_scale <= main.green_points
