extends "res://Scripts/Main/main_functions.gd"

@onready var uiCanvasLayer = $Camera2D/CanvasLayer as CanvasLayer
var brush = {"tool": null, "type": null, "image": null, "undertile": "Grass"}
var mapEditor = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	armyBuilder = false
	$Camera2D/CanvasLayer/SettingsPanel/MapName/TextEdit.text = mapName
	$Camera2D/CanvasLayer/SettingsPanel/MapID/TextEdit.text = mapID
	createGrid()
	uiCanvasLayer.readyUI()

func updateGrid():
	for i in tileControl.get_children():
		i.queue_free()
	createGrid()
	uiCanvasLayer.updateScreen()

func createGrid():
	var tileNo = 0
	for y in gridHeight:
		for x in gridWidth:
			lightGrid.append(true)
			var tile = preload("res://Nodes/tile.tscn").instantiate()
			tile.tileNo = tileNo
			tile.tileX = x
			tile.tileY = y
			tileControl.add_child(tile)
			tileNo += 1

func updateTile(tileX,tileY):
	for i in tileControl.get_children():
		if i.tileX == tileX:
			if i.tileY == tileY:
				i.queue_free()
				var tile = preload("res://Nodes/tile.tscn").instantiate()
				tile.tileNo = (tileY * gridWidth) + tileX
				tile.tileX = tileX
				tile.tileY = tileY
				tileControl.add_child(tile)
				uiCanvasLayer.updateScreen()
				break

func _on_save_button_pressed() -> void:
	saveMap()

func brushTile(tileX, tileY):
	var tile = tileGrid[tileY * gridWidth + tileX]
	if brush.tool == "height+":
		if tile.height < 10:
			tile.height += 1
	if brush.tool == "height-":
		if tile.height > 0:
			tile.height -= 1
	if brush.tool == "brush":
		tile.image = brush.image
		tile.type = brush.type
		if brush.type == 4:
			tile["undertile"] = brush.undertile
	for y in range(tileY-1,tileY+2):
		for x in range(tileX-1, tileX+2):
			updateTile(x,y)
