extends Skeleton3D

var bones
var bones_rest_trans = []
var material_mask
	
func _ready():
	bones = [$Hip, $Torso, $Head, $Left_Upper_Arm, $Left_Elbow, $Right_Upper_Arm, $Right_Elbow, $Left_Thigh, $Left_Lower_Leg, $Right_Thigh, $Left_Lower_Leg]

	for bone in bones:
		bones_rest_trans.append(bone.global_transform)

	material_mask = StandardMaterial3D.new()
	material_mask.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material_mask.albedo_color = Color(1, 1, 1)

	$/root/Node3D/SignalBro.connect('randomize', _on_randomize)
	$/root/Node3D/SignalBro.connect('mask_mode', _on_mask_mode)
	$/root/Node3D/SignalBro.connect('base_mode', _on_base_mode)
	
	physical_bones_start_simulation()

func _on_randomize():
	for i in range(bones.size()):
		var bone = bones[i]
		bone.global_transform = bones_rest_trans[i]
		bone.linear_velocity = Vector3(0, 0, 0)
		bone.angular_velocity = Vector3(0, 0, 0)
		bone.set_physics_process(false)
		await get_tree().create_timer(0.1)
		bone.set_physics_process(true)

func _on_mask_mode():
	$Realistic_White_Male_Low_Poly.material_override = material_mask
	
func _on_base_mode():
	$Realistic_White_Male_Low_Poly.material_override = null

