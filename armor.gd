class_name Armor
extends Upgrade

@export var bonus:float = 0.01

@export var base_point_cost:int = 25
@export var cost_scale:float = 10

func apply() -> void:
	main.armor -= bonus*count

func pay() -> void:
	main.green_points -= base_point_cost+count*base_point_cost*cost_scale

func cost() -> String:
	return "%d Laser Coins" % (base_point_cost+count*base_point_cost*cost_scale)
	
func valueFormatted(c: int)->String:
	return "Damage reduced by %d%%" % (bonus*c*100.0)

func avail() -> bool:
	return dependendable() && base_point_cost + count * base_point_cost * cost_scale <= main.green_points

func vis() -> bool:
	return dependendable() && main.green_points > 0
