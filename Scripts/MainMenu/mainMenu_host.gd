extends "mainMenu_local.gd"

func postReady():
	isMultiplayer = true
	if get_tree().get_current_scene().scenePassover.has("multiplayerPanels"):
		if OnlineHandler.multiplayer.is_server():
			openTab()

func postProcess():
	$NinePatchRect/TabContainer/Server/Status.text = "Status: "
	if OnlineHandler.peer == null:
		$NinePatchRect/TabContainer/Server/Status.text += "Server Not Started."
		$NinePatchRect/TabContainer/Server/HostButton.disabled = false
		$NinePatchRect/TabContainer/Server/StartButton.disabled = true
		$NinePatchRect/TabContainer/Server/IP/CopyButton.disabled = true
	else:
		$NinePatchRect/TabContainer/Server/IP.text = "IP: " + OnlineHandler.address
		$NinePatchRect/TabContainer/Server/IP/CopyButton.disabled = false
		if OnlineHandler.players.size() > 1:
			$NinePatchRect/TabContainer/Server/Status.text += "Player Connected!"
			$NinePatchRect/TabContainer/Server/StartButton.disabled = false
		else:
			$NinePatchRect/TabContainer/Server/Status.text += "Wating for players..."
			$NinePatchRect/TabContainer/Server/StartButton.disabled = true
		$NinePatchRect/TabContainer/Server/HostButton.disabled = true

func onOpenTab():
	if open:
		return
	open = true
	$NinePatchRect/TabContainer/Server/IP.text = "IP: "
	$AnimationPlayer.play("Open")

func _on_host_button_pressed() -> void:
	OnlineHandler.hostGame()

func sendToMain():
	var chosenMap = getChosenMap()
	var settings = getSettings()
	
	var mapData = {
	"mapName": chosenMap.name,
	"mapID": chosenMap.id,
	"mapWidth": chosenMap.gridWidth,
	"mapHeight": chosenMap.gridHeight,
	"mapGrid": chosenMap.grid,
	"armyBuilder": true,
	"armyHighestCosts": [0,0],
	"armyCostLimit": settings.armyPointLimit,
	"isMultiplayer": true
	}
	OnlineHandler.startGame(mapData, {"hostRed": false})

func onCloseTab():
	OnlineHandler.closeOnline()


func _on_copy_button_pressed() -> void:
	DisplayServer.clipboard_set(OnlineHandler.address)
