class_name Upgrade
extends Button

@export var base_id:String
@export var count:int = 0;
@export var max = -1
@export var dependsOn: Upgrade

@export var running: bool = false


var runtime:float

@export var texture: Texture2D

@export var main: Main

func _ready() -> void:
	visible = false
	modulate = Color(0.4,0.4,0.4)

func id(c: int) -> String:
	return base_id+str(c)

func apply(_c: int, _free: bool) -> void:
	pass
	
func text() -> String:
	return "An Upgrade?"

func avail() -> bool:
	return false

func vis() -> bool:
	return false

func _process(delta: float) -> void:
	if running && !disabled && (max < 0 || count < max):
		runtime+=delta
		scale = Vector2(1,1)*(sin(runtime*3)*0.1+1)
	
func check()->void:
	if vis(): 
				visible=true;
	if max >= 0 && count >= max:
		toggle_mode = true
		button_pressed = true
		disabled = false
	else: 
		disabled = !avail()

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
			apply(count, false)
			count+=1
			main.updateAll()
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
