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
	if len(OS.get_cmdline_args()) > 1:
		get_viewport().set_title(str(OS.get_cmdline_args()[1]))

@rpc("authority","call_remote")
func updatePlayers(p):
	players = p

func playerConnected(id):
	print("Player connected " + str(id))
	if multiplayer.is_server():
		players[id] = {}
		updatePlayers.rpc(players)
			

func startGame(mapData, serverData):
	if serverData.hostRed:
		for player in players:
			if player == playerId:
				players[player]["team"] = 0
			else:
				players[player]["team"] = 1
	else:
		var playerColor = range(len(players))
		playerColor.shuffle()
		var i = -1
		for player in players:
			i += 1
			players[player]["team"] = playerColor[i]
	updatePlayers.rpc(players)
	
	get_tree().get_current_scene().changeScene.rpc("res://Scenes/main.tscn", mapData)
	get_tree().get_current_scene().changeScene("res://Scenes/main.tscn", mapData)

func playerDisconnected(id):
	print("Player left me and took the kids  " + str(id))
	players.erase(id)
	if multiplayer.is_server():
		updatePlayers.rpc(players)
	else:
		closeOnline()
	
func connectedToServer():
	print("Weeeee're live!")
	
func connectionFailed():
	print("It bwoke 3:")

func closeOnline():
	if peer != null:
		peer.close()
		peer = null
	players = {}

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
