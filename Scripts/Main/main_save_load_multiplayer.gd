extends Node2D
@onready var mapName = get_parent().scenePassover.mapName
@onready var mapID = get_parent().scenePassover.mapID
@onready var gridWidth = get_parent().scenePassover.mapWidth
@onready var gridHeight = get_parent().scenePassover.mapHeight

@onready var tileGrid = get_parent().scenePassover.mapGrid

@onready var unitControl = get_node_or_null("Units")
@onready var tileControl = $Tiles

var turnNo = 0
var currentTurn #0 = Red, 1 = Blue, true = turn, false = ended turn
var armyHighestCosts

var armyBuilder = true
var selectedArmyNo = [0,0]
var armyGrid = []
var doArmyCostLimit = true
var armyCostLimit = 5000
var armyCosts = [0,0]

func saveMap():
	var mname = $Camera2D/CanvasLayer/SettingsPanel/MapName/TextEdit.text
	var id = $Camera2D/CanvasLayer/SettingsPanel/MapID/TextEdit.text
	if not mname:
		print("Invalid Map Name")
		return
	if not id:
		print("Invalid Map ID")
		return
		
	var saveFile = FileAccess.open("user://Saves//Maps//{id}.json".format({"id": id}), FileAccess.WRITE)
	var mapSaveString = {"grid": tileGrid, "name": mname, "gridWidth": gridWidth, "gridHeight": gridHeight}
	saveFile.store_line(JSON.stringify(mapSaveString, "\t"))
	print("saved successfully")

func saveGame():
	var saveData = generateSaveData()
	var saveFile = FileAccess.open("user://Saves//Games//{id}.json".format({"id": mapID}), FileAccess.WRITE)
	saveFile.store_line(JSON.stringify(saveData, "\t"))
	print("saved successfully")

func loadGame(saveData = null):
	if saveData == null:
		var openFile = FileAccess.open("user://Saves/Games/dual_peaks.json", FileAccess.READ)
		var json = JSON.new()
		var fileString = ""
		while openFile.get_position() < openFile.get_length():
			fileString += openFile.get_line()
		if not json.parse(fileString) == OK:
			print(json.get_error_message())
			return
		saveData = json.data
	if saveData.get("isMultiplayer") == null:
		saveData["isMultiplayer"] = false
	
	get_tree().current_scene.changeScene("res://Scenes/main.tscn",{
	"mapName": saveData.map.name,
	"mapID": "dual_peaks",
	"mapWidth": saveData.map.gridWidth,
	"mapHeight": saveData.map.gridHeight,
	"mapGrid": saveData.map.grid,
	"units": saveData.units,
	"playerTurn": saveData.playerTurn,
	"turnEnded": saveData.turnEnded,
	"armyHighestCosts": saveData.armyHighestCosts,
	"isMultiplayer": saveData.isMultiplayer,
	"armyBuilder": saveData.armyBuilder,
	"armyCostLimit": saveData.armyCostLimit,
	"turnNo": saveData.turnNo
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
		
	if armyBuilder:
		armyHighestCosts = armyCosts

	return {
		"map": mapSaveString,
		"units": unitSaveString,
		"playerTurn": currentTurn[0],
		"turnEnded": currentTurn[1],
		"armyHighestCosts": armyHighestCosts,
		"armyBuilder": armyBuilder,
		"armyCostLimit": armyCostLimit,
		"turnNo": turnNo
		}
