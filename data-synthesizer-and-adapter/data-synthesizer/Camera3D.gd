extends Camera3D

var man

func _ready():
	man = get_node('/root/Node3D/lol/Armature_001')
	get_node('/root/Node3D/Randomizer').connect('randomize', _on_randomize)

func _on_randomize():
	var character_position = man.global_transform.origin
	var random_position = Vector3(randf_range(-5, 5), randf_range(3, 8), randf_range(-5, 5))
	global_transform.origin = character_position + random_position
	look_at(character_position, Vector3.UP)
