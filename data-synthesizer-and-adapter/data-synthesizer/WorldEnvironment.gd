extends WorldEnvironment

var procedural_sky = preload("res://sky.tres")

func _ready():
	$/root/Node3D/SignalBro.connect('mask_mode', _on_mask_mode)
	$/root/Node3D/SignalBro.connect('base_mode', _on_base_mode)

func _on_mask_mode():
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0, 0, 0)
	
func _on_base_mode():
	environment.background_mode = Environment.BG_SKY
	environment.sky = procedural_sky
