extends Node

const GENERATOR_VERSION = '0.0.1'
var STARTUP_DATETIME = get_datetime() 
var OS_NAME = OS.get_name() 
var DIST_NAME = OS.get_distribution_name()
var CPU_NAME = OS.get_processor_name()
var GPU_NAME = OS.get_video_adapter_driver_info()

enum { GEN_POSE_MODE, GEN_VIEWPOINT_MODE, GEN_OCCLUSION_MODE, STOP }
var adapter_commands = {'stop': STOP, 'gen pose mode': GEN_POSE_MODE, 'gen viewpoint mode': GEN_VIEWPOINT_MODE, 'gen occlusion mode': GEN_OCCLUSION_MODE}
 
var socket = WebSocketPeer.new()
var target_tick = 60
var current_tick = 0

var node_randomize

func _ready():
	node_randomize = get_node('Randomizer')
	try_connect()

func try_connect():
	if socket.connect_to_url('ws://localhost:8000') == OK:
		print('Connecting to socket.')
	else:
		print('Could not connect to socket.') 

func _process(delta):

	send_data()
	#current_tick += 1
	#if current_tick >= target_tick:
	#	if send_data():
	#		node_randomize.emit()
	#		print('lol')
	#		current_tick = 0
 
func send_data():
	socket.poll()
	var state = socket.get_ready_state()

	if state == WebSocketPeer.STATE_CLOSED:
		print('Connection closed.')
		OS.delay_msec(2000) # FIXME: should sleep only when server not found, but failed to implement this with connect_to_url function
		try_connect()
		
	elif state == WebSocketPeer.STATE_CONNECTING or state == WebSocketPeer.STATE_CLOSING:
		pass

	elif state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count(): 
			var command_unchecked = socket.get_packet().get_string_from_utf8()
			var command = adapter_commands.get(command_unchecked)
			print('got command: %s' % command)
			match command:
				null:
					print('Command from adapter unrecognised: %s' % command_unchecked)

				GEN_VIEWPOINT_MODE:
					var json = extract_world_json()
					socket.send_text(json)
					print('data sent')
					return true

				GEN_POSE_MODE:
					print('not implemented')
					get_tree().quit()
					
				GEN_OCCLUSION_MODE:
					print('not implemented')
					get_tree().quit()

				STOP:
					print('Received stop command from adapter, shutting down.')
					get_tree().quit()
			return false
 
func get_datetime() -> String:
	var dt = Time.get_datetime_dict_from_system(false)
	return '%s-%s-%s %s:%s' % [dt['year'], dt['month'], dt['day'], dt['hour'], dt['minute']]

func screenshot_png_base64():
	var raw = get_viewport().get_texture().get_image().save_png_to_buffer()
	return Marshalls.raw_to_base64(raw)

## takes a screenshot of base image and segmentation mask, and puts it into json payload format
func extract_world_json():
	
	# 1st screenshot
	var raw = get_viewport().get_texture().get_image().save_png_to_buffer()
	var image_as_text = Marshalls.raw_to_base64(raw)

	# seg mask
	# 2nd screenshot
	
	var data = {
		'generator version': GENERATOR_VERSION,
		'host info': {
			'operating system': OS_NAME,
			'distribution': DIST_NAME,
			'cpu': CPU_NAME,
			'gpu': GPU_NAME,
		},
		'datetime started': STARTUP_DATETIME,
		'generator mode': 'viewpoint',
		'base image png base64': image_as_text,
		'segmentation mask png base64': image_as_text,
	} 
	return JSON.stringify(data)
	
				# GEN_VIEWPOINT_MODE:  
				# 	var raw = get_viewport().get_texture().get_image().save_png_to_buffer()
				# 	var image_as_text = Marshalls.raw_to_base64(raw)

				# 	var data = {
				# 		'generator version': GENERATOR_VERSION,
				# 		'host info': {
				# 			'operating system': OS_NAME,
				# 			'distribution': DIST_NAME,
				# 			'cpu': CPU_NAME,
				# 			'gpu': GPU_NAME,
				# 		},
				# 		'datetime started': STARTUP_DATETIME,
				# 		'generator mode': 'viewpoint',
				# 		'base image png base64': image_as_text,
				# 		'segmentation mask png base64': image_as_text,
				# 	} 
				# 	var json = JSON.stringify(data)
				# 	socket.send_text(json)
				# 	print('data sent')


