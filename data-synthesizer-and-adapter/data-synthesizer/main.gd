extends Node
var socket = WebSocketPeer.new()

enum { POSE_MODE, VIEWPOINT_MODE, OCCLUSION_MODE }
var mode = VIEWPOINT_MODE
var data_points = 12

const DATA = 'halla'

func _ready():
	parse_command_line_arguments()
	socket.connect_to_url('ws://localhost:8000')

func _process(delta): 
	socket.poll()
	var state = socket.get_ready_state()
	
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			if socket.get_packet().get_string_from_utf8() == "get data":
				socket.send_text(DATA)
				print("data sent")
			else:
				print("unrecognized message packet")
	elif state == WebSocketPeer.STATE_CLOSED:
		print("server closed")
		set_process(false) 

func parse_command_line_arguments():
	var args = Array(OS.get_cmdline_args())
	
	var i = 0
	while i < args.size():
		match args[i]:
			"--data-points":
				if i + 1 < args.size():
					data_points = int(args[i + 1])
					i += 1 
			"--mode":
				if i + 1 < args.size():

					var input = args[i + 1]
					if input == 'pose':
						mode = POSE_MODE
					elif input == 'viewpoint':
						mode = VIEWPOINT_MODE
					elif input == 'occlusion':
						mode = OCCLUSION_MODE
					else: 
						print("Invalid mode value: " + input)
						get_tree().quit()
					
					i += 1 
			"--help-inner":
				print_help()
				get_tree().quit()
			_:
				print("Unknown argument: " + args[i])
		i += 1
	
	print("Data points: %d, Mode: %s" % [data_points, mode])

func print_help():
	print("""
Usage: godot --script my_script.gd [options]
Options:
  --data-points <integer>    Specify the number of data points.
  --mode <value>                Specify the mode (pose, viewpoint, occlusion).
  --help-inner                                Show this help screen.
	""")

