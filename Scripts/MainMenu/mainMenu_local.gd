extends "main_menu_menu_base.gd"

var isMultiplayer = false

func _on_back_button_pressed() -> void:
	get_parent().get_node("Play").openTab()


func _on_start_button_pressed() -> void:
	sendToMain()
	
func getChosenMap():
	var mapSelectorNode = get_parent().get_node("MapSelector")
	if mapSelectorNode.selectedMap == null:
		return null
	var chosenMap = mapSelectorNode.mapJsonList[mapSelectorNode.selectedMap.dir][mapSelectorNode.selectedMap.map]
	chosenMap.get_or_add("id",mapSelectorNode.selectedMap.dir)
	return chosenMap

func getSettings():
	var settings = {}
	var armySettingsNode = get_node("NinePatchRect/TabContainer/Army/ScrollContainer/VBoxContainer")
	#var serverSettingsNode = get_node("NinePatchRect/TabContainer/Army/ScrollContainer/VBoxContainer")
	
	settings.get_or_add("armyPointLimit",int(armySettingsNode.get_node("PointLimit").value))
	
	return settings

func sendToMain():
	var chosenMap = getChosenMap()
	if chosenMap == null:
		return
	var settings = getSettings()
	get_tree().current_scene.changeScene("res://Scenes/main.tscn",{
	"mapName": chosenMap.name,
	"mapID": chosenMap.id,
	"mapWidth": chosenMap.gridWidth,
	"mapHeight": chosenMap.gridHeight,
	"mapGrid": chosenMap.grid,
	"armyBuilder": true,
	"armyHighestCosts": [0,0],
	"armyCostLimit": settings.armyPointLimit
	})
