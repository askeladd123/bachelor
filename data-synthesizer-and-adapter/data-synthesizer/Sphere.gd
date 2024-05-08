extends MeshInstance3D

var material_mask

func _ready():
	$/root/Node3D/SignalBro.connect('randomize', _on_randomize)
	$/root/Node3D/SignalBro.connect('mask_mode', _on_mask_mode)
	$/root/Node3D/SignalBro.connect('base_mode', _on_base_mode)
	
	material_mask = StandardMaterial3D.new()
	material_mask.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material_mask.albedo_color = Color(0, 0, 0)
	
func _on_randomize():
	global_position = Vector3(randf_range(-3, 3), randf_range(2, 2), randf_range(-2, 2))

func _on_mask_mode():
	material_override = material_mask
	
func _on_base_mode():
	material_override = null
