class_name Upgrade
extends Button

@export var base_id:String
@export var count:int = 0;
@export var max = -1
@export var dependsOn: Upgrade
@export var dependsOn2: Upgrade
@export var dependsOn3: Upgrade
@export var title: String

@export var running: bool = false


var runtime:float

@export var main: Main

func _ready() -> void:
	visible = false
	modulate = Color(0.4,0.4,0.4)

func id(c: int) -> String:
	return base_id+str(c)

func apply() -> void:
	pass
	
func pay() -> void:
	pass
	
func cost() ->String:
	return "free"

func textTitle()-> String:
	if (max < 0):
		return "%s Level %d" % [title, (count+1)]
	else:
		if (count >= max):
			return "%s MAX Level %d" % [title, (count)]
		else:
			return "%s Level %d/%d" % [title, (count+1), max]
		

func text() -> String:
	if (count > 0):
		if (max > 0 && count >= max):
			return textTitle() + "\nCurrently " + valueFormatted(count)
		return textTitle() + ": " + cost() + "\nUpgrade:" + valueFormatted(count + 1) + "\nCurrently " + valueFormatted(count)
	return textTitle() + ": " + cost() + "\nUpgrade:" + valueFormatted(1);
		
func valueFormatted(c:int)->String:
	return str(c)

func avail() -> bool:
	return false

func dependendable() -> bool:
	return (dependsOn == null || dependsOn.count > 0) && (dependsOn2 == null || dependsOn2.count > 0) && (dependsOn3 == null || dependsOn3.count > 0)

func vis() -> bool:
	return dependendable()

func _process(delta: float) -> void:
	if running && !disabled && (max < 0 || count < max):
		runtime+=delta
		scale = Vector2(1,1)*(sin(Time.get_ticks_msec()*0.005)*0.05+1)
	
func check()->void:
	if vis(): 
		visible=true;
	if max >= 0 && count >= max:
		toggle_mode = true
		button_pressed = true
		disabled = false
		scale = Vector2(1,1)
	else: 
		disabled = !avail()
		if disabled:
			scale = Vector2(1,1)

func run() -> void:
	running = true;
	modulate = Color(1,1,1)
	focus_mode = Control.FOCUS_ALL
	runtime = 0;

func stop() -> void:
	running = false
	focus_mode = Control.FOCUS_NONE
	release_focus()
	modulate = Color(0.4,0.4,0.4)
	scale = Vector2(1,1)

func _on_pressed() -> void:
	if max < 0 || count < max:
		if running && avail():
			pay()
			count+=1
			main.apply_upgrades()
			main.updateAll()
			main.displayUpgradeText(text())
	check()
		


func _on_focus_entered() -> void:
	main.displayUpgradeText(text())


func _on_focus_exited() -> void:
	main.displayUpgradeText("")

func _on_mouse_entered() -> void:
	if !running:
		main.displayUpgradeText(text())
	else:
		grab_focus()

func _on_mouse_exited() -> void:
	pass;
