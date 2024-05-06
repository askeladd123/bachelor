extends Skeleton3D

var bone_id_hip
var bone_id_torso
var bone_id_head
var bone_id_left_upper_arm
var bone_id_left_elbow
var bone_id_left_thigh
var bone_id_left_lower_leg
var bone_id_right_upper_arm
var bone_id_right_elbow
var bone_id_right_thigh
var bone_id_right_lower_leg

func _ready():
	bone_id_hip = find_bone('Hip')
	bone_id_torso = find_bone('Torso')
	bone_id_head = find_bone('Head')
	bone_id_left_upper_arm = find_bone('Left_Upper_Arm')
	bone_id_left_elbow = find_bone('Left_Elbow')
	bone_id_left_thigh = find_bone('Left_Thigh')
	bone_id_left_lower_leg = find_bone('Left_Lower_Leg')
	bone_id_right_upper_arm = find_bone('Right_Upper_Arm')
	bone_id_right_elbow = find_bone('Right_Elbow')
	bone_id_right_thigh = find_bone('Right_Thigh')
	bone_id_right_lower_leg = find_bone('Right_Lower_Leg')
	get_node('/root/Node3D/Randomizer').connect('randomize', _on_randomize)
	physical_bones_start_simulation()

func _on_randomize():
	pass
	#print('resetting')
	#physical_bones_stop_simulation()
	
	#var physical_bones = [$Hip, $Torso, $Head, $Left_Upper_Arm, $Left_Elbow, $Right_Upper_Arm, $Right_Elbow, $Left_Thigh, $Left_Lower_Leg, $Right_Thigh, $Left_Lower_Leg]
	#for bone in physical_bones:
	#	bone.linear_velocity = Vector3(0, 0, 0)
	#	bone.angular_velocity = Vector3(0, 0, 0)
	
	#await get_tree().process_frame
	#reset_bone_poses()
	#clear_bones_global_pose_override()
	#physical_bones_start_simulation()
	
	#bone_id_torso.apply_central_impulse()
	  
	#for i in range(get_bone_count()):
	#	var random_rotation = Quaternion(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
	#	set_bone_pose_rotation(i, random_rotation)
