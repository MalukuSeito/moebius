class_name AttackUpgrade
extends Upgrade

@export var bonus:float = 1

@export var base_point_cost:int = 10
@export var cost_scale:float = 0.5

func apply(c: int, free: bool) -> void:
	main.damage += bonus
	if !free:
		main.base_points -= base_point_cost+c*base_point_cost*cost_scale

func avail() -> bool:
	return (dependsOn == null || dependsOn.count > 0) && base_point_cost + count * base_point_cost * cost_scale <= main.base_points
	
func text() -> String:
	if (count > 0) :
		if (count >= max):
				return "Attack Upgrade\n Currently" + str(count*bonus) + " damage"
		return "Attack Upgrade: +" + str((1 + count)*bonus) + " damage.\n Currently +" + str(count*bonus) + " damage"
	return "Attack Upgrade: +" + str((1 + count)*bonus) + " damage."
	
func vis() -> bool:
	return (dependsOn == null || dependsOn.count > 0) && main.base_points > 0
