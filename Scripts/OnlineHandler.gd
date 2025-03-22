extends Node

var players = {}
var address
var port = 6969
var peer
var playerId

func _ready() -> void:
	multiplayer.peer_connected.connect(playerConnected)
	multiplayer.peer_disconnected.connect(playerDisconnected)
	multiplayer.connected_to_server.connect(connectedToServer)
	multiplayer.connection_failed.connect(connectionFailed)
	get_viewport().set_title(str(OS.get_cmdline_args()[1]))

@rpc("authority","call_remote")
func updatePlayers(p):
	players = p

func playerConnected(id):
	print("Player connected " + str(id))
	if multiplayer.is_server():
		players[id] = {}
		updatePlayers.rpc(players)
		if get_tree().get_current_scene().get_child(0).name == "MainMenu":
			get_tree().get_current_scene().get_node("MainMenu/MainMenuUI/MapHostTab/Host/Player").text = "Connection: Player Connected"
			

func startGame():
	if get_tree().get_current_scene().get_node("MainMenu/MainMenuUI/MapHostTab/Host/ArmyCostContainer2/CheckButton").button_pressed:
		for player in players:
			if player == playerId:
				players[player]["team"] = 0
			else:
				players[player]["team"] = 1
	else:
		var playerColor = range(len(players))
		playerColor.shuffle()
		for player in players:
			players[player]["team"] = playerColor[0]
			playerColor.pop_front()
	updatePlayers.rpc(players)
	
	var armyCostLimit = get_tree().get_current_scene().get_node("MainMenu/MainMenuUI/MapHostTab/Host/ArmyCostContainer/TextEdit").get_text()
	if armyCostLimit == "":
		armyCostLimit = 5000
	else:
		armyCostLimit = int(armyCostLimit)
	
	var openFile = FileAccess.open("res://Saves/Maps/Official/dual_peaks.json", FileAccess.READ)
	var json = JSON.new()
	var fileString = ""
	while openFile.get_position() < openFile.get_length():
		fileString += openFile.get_line()
	if not json.parse(fileString) == OK:
		print(json.get_error_message())
		return
	var mapData = json.data
	mapData = {"mapName": mapData.name, "mapID": "dual_peaks", "mapWidth": mapData.gridWidth, "mapHeight": mapData.gridHeight, "mapGrid": mapData.grid, "isMultiplayer": true, "armyBuilder": true, "armyHighestCosts": [0,0], "armyCostLimit": armyCostLimit}
	get_tree().get_current_scene().changeScene.rpc("res://Scenes/main.tscn", mapData)
	get_tree().get_current_scene().changeScene("res://Scenes/main.tscn", mapData)

func playerDisconnected(id):
	print("Player left me and took the kids  " + str(id))
	if get_tree().get_current_scene().get_child(0).name == "MainMenu":
		if multiplayer.is_server():
			players.erase(id)
			updatePlayers.rpc(players)
			if get_tree().get_current_scene().get_child(0).name == "MainMenu":
				get_tree().get_current_scene().get_node("MainMenu/MainMenuUI/MapHostTab/Host/Player").text = "Connection: Player Disconnected"
	
func connectedToServer():
	print("Weeeee're live!")
	
func connectionFailed():
	print("It bwoke 3:")

func closeOnline():
	peer = null

func hostGame():
	players = {}
	if peer != null:
		peer.close()
	peer = ENetMultiplayerPeer.new()
	address = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),(IP.TYPE_IPV4))
	var error = peer.create_server(port, 2)
	if error != OK:
		printerr(error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	playerId = multiplayer.get_unique_id()
	players[multiplayer.get_unique_id()] = {}
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting For Players...")
	get_tree().get_current_scene().get_node("MainMenu/MainMenuUI/MapHostTab/Host/Player").text = "Connection: Waiting"

func joinGame() -> void:
	players = {}
	if peer != null:
		peer.close()
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	playerId = multiplayer.get_unique_id()
	print("Connecting...")

@rpc("any_peer","call_remote","reliable")
func onlineLoad(saveData):
	get_tree().get_current_scene().get_child(0).loadGame(saveData)
	get_viewport().request_attention()
