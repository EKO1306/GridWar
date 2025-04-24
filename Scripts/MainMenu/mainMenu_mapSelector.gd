extends "main_menu_menu_base.gd"
var mapJsonList
var selectedMap

func onOpenTab():
	for i in $NinePatchRect/TabContainer/Official/VBoxContainer.get_children():
		i.queue_free()
	for i in $NinePatchRect/TabContainer/Custom/VBoxContainer.get_children():
		i.queue_free()
	
	#If the maps directory doesn't exist, make one.
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("user://Saves//Maps"):
		dir.make_dir_recursive("user://Saves//Maps")
	
	mapJsonList = {"Official": {}, "Custom": {}}
	updateMapList("Official")
	updateMapList("Custom")

func updateMapList(dir):
	openDirectory(dir)
	var mapContainerNode = get_node("NinePatchRect/TabContainer/" + dir + "/VBoxContainer")
	var counter = -1
	for i in mapJsonList[dir]:
		counter += 1
		var buttonNode = preload("res://Nodes/MainMenu/map_selector_button.tscn").instantiate()
		buttonNode.text = mapJsonList[dir][i].name
		buttonNode.connect("pressed", selectMap.bind(dir, i))
		mapContainerNode.add_child(buttonNode)
		

func selectMap(dir, map):
	selectedMap = {"dir": dir, "map": map}
	var mapDetails = mapJsonList[dir][map]
	$NinePatchRect/MapName.text = mapDetails.name
	$NinePatchRect/MapSize.text = "{0}x{1}".format([int(mapDetails.gridWidth),int(mapDetails.gridHeight)])

func openDirectory(dir):
	var path
	if dir == "Official":
		path = "res://Saves/Maps"
	elif dir == "Custom":
		path = "user://Saves/Maps"
	else:
		return false
	var mapFolder = DirAccess.open(path) as DirAccess
	var mapFiles = {}
	for i in mapFolder.get_files():
		var mapDir = "{directory}/{file}".format({"file": i, "directory": path})
		var openFile = FileAccess.open((mapDir), FileAccess.READ)
		var json = JSON.new()
		var fileString = ""
		while openFile.get_position() < openFile.get_length():
			fileString += openFile.get_line()
		if not json.parse(fileString) == OK:
			print(json.get_error_message())
			return
		mapJsonList[dir].get_or_add(i.left(-5),json.data)
