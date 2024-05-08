extends Node

const TARGET_IMAGES = 512
const GENERATOR_VERSION = '0.1.0'
const DATA_DIR_NAME = 'generated-data'
var STARTUP_DATETIME = get_datetime() 
 
var target_tick = 60
var current_tick = 0

var generated_images = 0
var rng

var material_mask

func random_tick():
	return rng.randi_range(2, 120)

func path_prefix(generated_images):
	return 'res://%s/v%s_%s_n%s' % [DATA_DIR_NAME, GENERATOR_VERSION, STARTUP_DATETIME, generated_images]
	

func _ready():
	rng = RandomNumberGenerator.new()

	material_mask = StandardMaterial3D.new()
	material_mask.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material_mask.albedo_color = Color(1, 1, 1)

	$SignalBro.emit_randomize()
	target_tick = random_tick()
	print('Generating images and saving to folder `%s`.' % DATA_DIR_NAME)

func _process(delta):
	current_tick += 1
	if current_tick == target_tick:
		generated_images += 1

		get_viewport().get_texture().get_image().save_png('%s_base.png' % path_prefix(generated_images))
		$SignalBro.emit_mask_mode()
		
	if current_tick > target_tick:
		get_viewport().get_texture().get_image().save_png('%s_mask.png' % path_prefix(generated_images))
		print('- image %s of %s, ticks %s' % [generated_images, TARGET_IMAGES, current_tick])

		if generated_images >= TARGET_IMAGES:
			print('Generated %s images in folder `%s`.' % [generated_images, DATA_DIR_NAME])
			get_tree().quit()

		$SignalBro.emit_base_mode()
		current_tick = 0
		$SignalBro.emit_randomize()
		target_tick = random_tick()

func get_datetime() -> String:
	var dt = Time.get_datetime_dict_from_system(false)
	return 'ymdhms%s-%s-%s-%s-%s-%s' % [dt['year'], dt['month'], dt['day'], dt['hour'], dt['minute'], dt['second']]
