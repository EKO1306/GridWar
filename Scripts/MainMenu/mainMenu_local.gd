extends "main_menu_menu_base.gd"

func _on_back_button_pressed() -> void:
	get_parent().get_node("Main").openTab()


func _on_start_button_pressed() -> void:
	var mapSelectorNode = get_parent().get_node("MapSelector")
	var chosenMap = mapSelectorNode.mapJsonList[mapSelectorNode.selectedMap.dir][mapSelectorNode.selectedMap.map]
	get_tree().current_scene.changeScene("res://Scenes/main.tscn",{
	"mapName": chosenMap.name,
	"mapID": mapSelectorNode.selectedMap.dir,
	"mapWidth": chosenMap.gridWidth,
	"mapHeight": chosenMap.gridHeight,
	"mapGrid": chosenMap.grid,
	"armyBuilder": true,
	"armyHighestCosts": null,
	"armyCostLimit": 9999
	})
