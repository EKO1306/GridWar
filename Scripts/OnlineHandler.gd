extends Node

var players = {}
var address
var port = 6969
var peer
var id

func _ready() -> void:
	multiplayer.peer_connected.connect(playerConnected)
	multiplayer.peer_disconnected.connect(playerDisconnected)
	multiplayer.connected_to_server.connect(connectedToServer)
	multiplayer.connection_failed.connect(connectionFailed)

@rpc("authority","call_remote")
func updatePlayers(p):
	players = p

func playerConnected(id):
	print("Player connected " + str(id))
	if multiplayer.is_server():
		players[id] = {"team": 1}
		if get_tree().get_current_scene().get_child(0).name == "MainMenu":
			var openFile = FileAccess.open("res://Saves/Maps/Official/dual_peaks.json", FileAccess.READ)
			var json = JSON.new()
			var fileString = ""
			while openFile.get_position() < openFile.get_length():
				fileString += openFile.get_line()
			if not json.parse(fileString) == OK:
				print(json.get_error_message())
				return
			var mapData = json.data
			mapData = {"mapName": mapData.name, "mapID": "dual_peaks", "mapWidth": mapData.gridWidth, "mapHeight": mapData.gridHeight, "mapGrid": mapData.grid, "isMultiplayer": true}
			updatePlayers.rpc(players)
			get_tree().get_current_scene().changeScene.rpc("res://Scenes/main.tscn", mapData)
			get_tree().get_current_scene().changeScene("res://Scenes/main.tscn", mapData)
			#get_tree().get_current_scene().get_node("MainMenu/MainMenuUI/MapHostTab/Host/Player").text = "Connection: CONNECTED"

func playerDisconnected(id):
	print("Player left me and took the kids  " + str(id))
	
func connectedToServer():
	print("Weeeee're live!")
	
func connectionFailed():
	print("It bwoke 3:")

func closeOnline():
	peer = null

func hostGame():
	players = {}
	peer = ENetMultiplayerPeer.new()
	address = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),(1))
	var error = peer.create_server(port, 2)
	if error != OK:
		printerr(error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	id = multiplayer.get_unique_id()
	players[multiplayer.get_unique_id()] = {"team": 0}
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting For Players...")

func joinGame() -> void:
	players = {}
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	id = multiplayer.get_unique_id()
	print("Connecting...")
