class_name SpreadShot
extends Upgrade

@export var bonus:int = 1

@export var base_point_cost:int = 25
@export var cost_scale:float = 10

func apply() -> void:
	main.multishot += bonus*count

func pay() -> void:
	main.base_points -= base_point_cost+count*base_point_cost*cost_scale

func cost() -> String:
	return "%d Blue Credits" % (base_point_cost+count*base_point_cost*cost_scale)
	
func valueFormatted(c: int)->String:
	return "+%d additional projectiles" % (bonus*c*2)

func avail() -> bool:
	return dependendable() && base_point_cost + count * base_point_cost * cost_scale <= main.base_points
