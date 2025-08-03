class_name Boss
extends Enemy

func damage(d:float)->float:
	if hp <= 0:
		return -d;
	if max_hp <= 0:
		max_hp = hp;
	hp-=d
	if main.vampiric > 0:
		main.vamp(d)
	if hp <= 0:
		queue_free()
		if main != null:
			var val:float = clampf((log(max_hp)/log(10)), 1, 100) 
			main.spawn_point(position, show_behind_parent, 10, int(val))
			main.spawn_green(position, show_behind_parent, 2, int(val))
		return -hp
	else:
		var off = 0.5+0.5*hp/max_hp
		modulate = Color(off, off, off)
		return 0
