extends CanvasLayer

@onready var mapEditorNameLine = $MapEditorTab/New/MapName/TextEdit
@onready var mapEditorIDLine = $MapEditorTab/New/MapID/TextEdit
@onready var mapEditorWidthLine = $MapEditorTab/New/MapWidth/TextEdit
@onready var mapEditorHeightLine = $MapEditorTab/New/MapHeight/TextEdit

func _ready():
	updateMapList("res://Saves/Maps/Official","MapPlayTab/Official","Play")
	updateMapList("res://Saves/Maps/Custom","MapPlayTab/Custom", "Play")
	updateMapList("res://Saves/Maps/Official","MapEditorTab/Official","Editor")
	updateMapList("res://Saves/Maps/Custom","MapEditorTab/Custom", "Editor")

func updateMapList(directory, panelDir, playAction):
	var mapDirectoryOfficial = DirAccess.open(directory) as DirAccess
	for i in mapDirectoryOfficial.get_files():
		var openFile = FileAccess.open("{directory}/{file}".format({"file": i, "directory": directory}), FileAccess.READ)
		var json = JSON.new()
		var fileString = ""
		while openFile.get_position() < openFile.get_length():
			fileString += openFile.get_line()
		if not json.parse(fileString) == OK:
			print(json.get_error_message())
			return
		var mapData = json.data
		
		var panel = preload("res://Nodes/Menu/map_selection_panel.tscn").instantiate()
		panel.get_node("Panel/MapName").text = mapData.name
		panel.get_node("Panel/MapSize").text = str(mapData.gridWidth) + "x" + str(mapData.gridHeight)
		panel.get_node("Panel/PlayButton").mapData = {"mapName": mapData.name, "mapID": i.trim_suffix(".json"), "mapWidth": mapData.gridWidth, "mapHeight": mapData.gridHeight, "mapGrid": mapData.grid}
		panel.get_node("Panel/PlayButton").buttonType = playAction
		get_node(panelDir).add_child(panel)

func _on_play_button_pressed() -> void:
	$MapEditorTab.visible = false
	$MapPlayTab.visible = not $MapPlayTab.visible

func _on_map_editor_button_pressed() -> void:
	if len(mapEditorNameLine.text) == 0:
		return
	if len(mapEditorIDLine.text) == 0:
		return
	if len(mapEditorWidthLine.text) == 0:
		return
	if len(mapEditorHeightLine.text) == 0:
		return
	var mapName = mapEditorNameLine.text
	var mapID = mapEditorIDLine.text
	var mapWidth = int(mapEditorWidthLine.text)
	var mapHeight = int(mapEditorHeightLine.text)
	var mapGrid = []
	for y in mapWidth:
		for x in mapHeight:
			mapGrid.append({"type":0, "height":2, "image":"Grass"})

	get_tree().current_scene.changeScene("res://Scenes/map_editor.tscn",{
	"mapName": mapName,
	"mapID": mapID,
	"mapWidth": mapWidth,
	"mapHeight": mapHeight,
	"mapGrid": mapGrid
	})


func _on_editor_pressed() -> void:
	$MapPlayTab.visible = false
	$MapEditorTab.visible = not $MapEditorTab.visible
