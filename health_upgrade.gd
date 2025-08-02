class_name HealthUpgrade
extends Upgrade


@export var bonus:float = 5

@export var base_point_cost:int = 10
@export var cost_scale:float = 1

func apply() -> void:
	main.max_health += bonus*count

func pay() -> void:
	main.base_points -= base_point_cost+count*base_point_cost*cost_scale

func avail() -> bool:
	return dependendable() && base_point_cost + count * base_point_cost * cost_scale <= main.base_points

func cost() -> String:
	return "%d Blue Credits" % (base_point_cost+count*base_point_cost*cost_scale)
	
func valueFormatted(c: int)->String:
	return "+%d HP" % (bonus*c)
