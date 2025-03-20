extends CanvasLayer

@onready var main = get_parent().get_parent()

@onready var uiLayoutPanel = get_node("LayoutPanel") as Panel

# Called when the node enters the scene tree for the first time.
func readyUI() -> void:
	for y in range(main.gridHeight):
		for x in range(main.gridWidth):
			var tile = preload("res://Nodes/mapEditor/map_editor_tile.tscn").instantiate()
			tile.position = Vector2(x * 14 + 4,y * 14 + 4)
			uiLayoutPanel.add_child(tile)
	uiLayoutPanel.size = Vector2(main.gridWidth * 14 + 8,main.gridHeight * 14 + 8)
	updateScreen()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var localMousePos = floor((uiLayoutPanel.get_local_mouse_position() - Vector2(4,4)) / 14)
	if localMousePos.x < 0:
		$LayoutPanel/SelectionMarker.visible = false
	elif localMousePos.y < 0:
		$LayoutPanel/SelectionMarker.visible = false
	elif localMousePos.x >= main.gridWidth:
		$LayoutPanel/SelectionMarker.visible = false
	elif localMousePos.y >= main.gridHeight:
		$LayoutPanel/SelectionMarker.visible = false
	else:
		$LayoutPanel/SelectionMarker.visible = true
		$LayoutPanel/SelectionMarker.position = localMousePos * 14 + Vector2(3,3)
		if Input.is_action_just_pressed("left_click"):
			updateTile(localMousePos.x, localMousePos.y)

func updateTile(tileX, tileY):
	var tile = main.tileGrid[tileY * main.gridWidth + tileX]
	if main.brush.tool == "height+":
		if tile.height < 10:
			tile.height += 1
	if main.brush.tool == "height-":
		if tile.height > 0:
			tile.height -= 1
	if main.brush.tool == "brush":
		tile.image = main.brush.image
		tile.type = main.brush.type
	main.updateGrid()

func updateScreen():
	var i = -1
	for tile in uiLayoutPanel.get_children():
		if tile.name == "SelectionMarker":
			continue
		i += 1
		if main.tileGrid[i].type == 0:
			tile.color = Color(0.5, 0.5, 0.5)
		elif main.tileGrid[i].type == 1:
			tile.color = Color(0.5, 0.25, 0.5)
		elif main.tileGrid[i].type == 2:
			tile.color = Color(0.5, 0.9, 0.5)
		elif main.tileGrid[i].type == 3:
			tile.color = Color(0.1, 0.25, 0)
		elif main.tileGrid[i].type == 4:
			tile.color = Color(0.75, 0.5, 0)
		else:
			tile.color = Color(0, 0, 0)
		tile.color *= 0.8 + (main.tileGrid[i].height * 0.1)


func _on_settings_button_pressed() -> void:
	$SettingsPanel.visible = not $SettingsPanel.visible
