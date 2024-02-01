extends Node
 
var socket = WebSocketPeer.new()
const DATA = "halla"

func _ready():  
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
