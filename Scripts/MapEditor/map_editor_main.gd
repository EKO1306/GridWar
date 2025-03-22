extends "res://Scripts/Main/main_functions.gd"

@onready var uiCanvasLayer = $Camera2D/CanvasLayer as CanvasLayer
var brush = {"tool": null, "type": null, "image": null}
var mapEditor = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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


func _on_save_button_pressed() -> void:
	saveMap()
