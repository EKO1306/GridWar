extends Node2D
@onready var mapName = get_parent().scenePassover.mapName
@onready var mapID = get_parent().scenePassover.mapID
@onready var gridWidth = get_parent().scenePassover.mapWidth
@onready var gridHeight = get_parent().scenePassover.mapHeight

@onready var tileGrid = get_parent().scenePassover.mapGrid

@onready var unitControl = $Units
@onready var tileControl = $Tiles
var currentTurn = [1,false] #0 = Red, 1 = Blue, true = turn, false = ended turn
var armyHighestCosts

func saveMap():
	var mname = $Camera2D/CanvasLayer/SettingsPanel/MapName/TextEdit.text
	var id = $Camera2D/CanvasLayer/SettingsPanel/MapID/TextEdit.text
	if not mname:
		print("Invalid Map Name")
		return
	if not id:
		print("Invalid Map ID")
		return
		
	var saveFile = FileAccess.open("res://Saves//Maps//Custom//{id}.json".format({"id": id}), FileAccess.WRITE)
	var mapSaveString = {"grid": tileGrid, "name": mname, "gridWidth": gridWidth, "gridHeight": gridHeight}
	saveFile.store_line(JSON.stringify(mapSaveString, "\t"))
	print("saved successfully")

func saveGame():
	var saveData = generateSaveData()
	var saveFile = FileAccess.open("res://Saves//Games//{id}.json".format({"id": mapID}), FileAccess.WRITE)
	saveFile.store_line(JSON.stringify(saveData, "\t"))
	print("saved successfully")

@rpc("any_peer","call_remote","reliable")
func loadGame(saveData = null):
	if saveData == null:
		var openFile = FileAccess.open("res://Saves/Games/dual_peaks.json", FileAccess.READ)
		var json = JSON.new()
		var fileString = ""
		while openFile.get_position() < openFile.get_length():
			fileString += openFile.get_line()
		if not json.parse(fileString) == OK:
			print(json.get_error_message())
			return
		saveData = json.data
	print("ae")
	
	get_tree().current_scene.changeScene("res://Scenes/main.tscn",{
	"mapName": saveData.map.name,
	"mapID": "dual_peaks",
	"mapWidth": saveData.map.gridWidth,
	"mapHeight": saveData.map.gridHeight,
	"mapGrid": saveData.map.grid,
	"units": saveData.units,
	"playerTurn": currentTurn[0],
	"turnEnded": currentTurn[1],
	"armyHighestCosts": armyHighestCosts
	})
	
func generateSaveData():
	var unitSaveString = []
	for unit in unitControl.get_children():
		if unit.is_in_group("Unit"):
			unitSaveString.append(unit.saveUnit())
	
	var mapSaveString = {
		"grid": tileGrid,
		"name": mapName,
		"gridWidth": gridWidth,
		"gridHeight": gridHeight}

	return {
		"map": mapSaveString,
		"units": unitSaveString,
		"playerTurn": currentTurn[0],
		"turnEnded": currentTurn[1],
		"armyHighestCosts": armyHighestCosts
	}
