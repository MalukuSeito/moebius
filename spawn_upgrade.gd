class_name SpawnUpgrade
extends Upgrade

@export var bonus:float = 1.1

@export var base_point_cost:int = 20
@export var cost_scale:float = 1.5

func apply() -> void:
	main.spawnrate *=((bonus-1)*count)+1
	main.max_spawn += count;

func pay() -> void:
	main.base_points -= base_point_cost+count*base_point_cost*cost_scale

func avail() -> bool:
	return dependendable() && base_point_cost + count * base_point_cost * cost_scale <= main.base_points
	
func cost() -> String:
	return "%d Blue Credits" % (base_point_cost+count*base_point_cost*cost_scale)
	
func valueFormatted(c: int)->String:
	return "+%d%%" % ((c*(bonus-1))*100)
