extends "main_menu_menu_base.gd"
var mapJsonList
var selectedMap

var mapLoadThread: Thread
var mapSemaphore: Semaphore

func postReady():
	mapLoadThread = Thread.new()
	mapSemaphore = Semaphore.new()
	mapLoadThread.start(updateMapList)

func onOpenTab():
	if open:
		return
	open = true
	$AnimationPlayer.play("Open")
	
	for i in $NinePatchRect/NinePatchRect/TabContainer/Official/VBoxContainer.get_children():
		i.queue_free()
	for i in $NinePatchRect/NinePatchRect/TabContainer/Custom/VBoxContainer.get_children():
		i.queue_free()
	
	#If the maps directory doesn't exist, make one.
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("user://Saves//Maps"):
		dir.make_dir_recursive("user://Saves//Maps")
	mapJsonList = {"Official": {}, "Custom": {}}
	
	mapSemaphore.post()

func updateMapList():
	while true:
		mapSemaphore.wait()
		for dir in ["Official","Custom"]:
			openDirectory(dir)
			@warning_ignore("unused_variable")
			var counter = -1
			for i in mapJsonList[dir]:
				counter += 1
				var buttonNode = preload("res://Nodes/MainMenu/map_selector_button.tscn").instantiate()
				buttonNode.text = mapJsonList[dir][i].name
				buttonNode.connect("pressed", selectMap.bind(dir, i))
				createButton.call_deferred(dir,buttonNode)
		if selectedMap == null:
			selectMap.call_deferred("Official","dual_peaks")

func createButton(dir,buttonNode):
	var mapContainerNode = get_node("NinePatchRect/NinePatchRect/TabContainer/" + dir + "/VBoxContainer")
	mapContainerNode.add_child.call_deferred(buttonNode)

func selectMap(dir, map):
	var mapPath
	if dir == "Official":
		mapPath = "res://Saves/Maps"
	elif dir == "Custom":
		mapPath = "user://Saves/Maps"
	mapPath = "{path}/{map}".format({"path":mapPath,"map":map})
	selectedMap = {"dir": dir, "map": map}
	var mapDetails = mapJsonList[dir][map]
	$NinePatchRect/MapName.text = mapDetails.name
	$NinePatchRect/MapSize.text = "{0}x{1}".format([int(mapDetails.gridWidth),int(mapDetails.gridHeight)])
	$NinePatchRect/MapAuthor.text = "by " + mapDetails.author
	if ResourceLoader.exists(mapPath + ".png"):
		var mapImage = load(mapPath + ".png")
		$NinePatchRect/MapImage.texture = mapImage
	else:
		$NinePatchRect/MapImage.texture = PlaceholderTexture2D.new()

func openDirectory(dir):
	var path
	if dir == "Official":
		path = "res://Saves/Maps"
	elif dir == "Custom":
		path = "user://Saves/Maps"
	else:
		return false
	var mapFolder = DirAccess.open(path) as DirAccess
	@warning_ignore("unused_variable")
	var mapFiles = {}
	for i in mapFolder.get_files():
		if not i.ends_with(".json"):
			continue
		var mapDir = "{directory}/{file}".format({"file": i, "directory": path})
		var openFile = FileAccess.open((mapDir), FileAccess.READ)
		var json = JSON.new()
		var fileString = ""
		while openFile.get_position() < openFile.get_length():
			fileString += openFile.get_line()
		if not json.parse(fileString) == OK:
			print(json.get_error_message())
			return
			
		json.data.get_or_add("author", "Unknown")
		mapJsonList[dir].get_or_add(i.left(-5),json.data)
