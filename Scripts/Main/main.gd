extends "main_functions.gd"

var selectedUnit
var selectedAction
@export var spawnUnitsRed = false
@export var spawnUnitsBlue = false

var mapEditor = false
@export var debugMode = true
@onready var isMultiplayer = get_parent().scenePassover.get("isMultiplayer") != null

@onready var uiCanvas = $Camera2D/CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().scenePassover.get("playerTurn") != null:
		currentTurn = [get_parent().scenePassover.get("playerTurn"),get_parent().scenePassover.get("turnEnded")]
	else:
		currentTurn = [1,false]
	if get_parent().scenePassover.get("armyBuilder") != null:
		armyBuilder = get_parent().scenePassover.get("armyBuilder")
		armyHighestCosts = get_parent().scenePassover.get("armyHighestCosts")
		armyCostLimit = get_parent().scenePassover.get("armyCostLimit")
	if armyCostLimit <= 0:
		doArmyCostLimit = false
	if debugMode:
		armyBuilder = false
	if get_parent().scenePassover.get("turnNo") != null:
		turnNo = get_parent().scenePassover.get("turnNo")
	createGrid()
	for y in range(gridHeight):
		for x in range(gridWidth):
			if tileGrid[y * gridWidth + x].type == 1:
				armyGrid.append(null)
				continue
			if x < 3:
				armyGrid.append(0)
				continue
			if x >= gridWidth - 3:
				armyGrid.append(1)
				continue
			armyGrid.append(null)
	if get_parent().scenePassover.get("units") != null:
		loadUnits(get_parent().scenePassover.units)
		currentTurn[0] = get_parent().scenePassover.playerTurn
		currentTurn[1] = get_parent().scenePassover.turnEnded
		if isMultiplayer:
			endTurn(false,true)
		else:
			updateScreen()
	else:
		massSpawnUnits()
		endTurn(true)

func loadUnits(units):
	for unit in units:
		var loadUnitNode = load(unit.pathName).instantiate()
		loadUnitNode.statName = unit.name
		loadUnitNode.statMaxHealth = unit.maxHealth
		loadUnitNode.statHealth = unit.health
		loadUnitNode.statMaxMovement = unit.maxMovement
		loadUnitNode.statMovement = unit.movement
		loadUnitNode.statMaxActions = unit.maxActions
		loadUnitNode.statActions = unit.actions
		loadUnitNode.statCost = unit.cost
		loadUnitNode.statTraits = unit.traitsList
		loadUnitNode.statActionList = unit.actionList
		loadUnitNode.statusList = unit.statusList
	
		loadUnitNode.gridX = unit.gridX
		loadUnitNode.gridY = unit.gridY
		loadUnitNode.unitTeam = unit.team
		if unit.spriteFlipped:
			loadUnitNode.get_node("Sprites").scale = Vector2(-1,1)
		unitControl.add_child(loadUnitNode)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("pause_game"):
		get_tree().paused = not get_tree().paused
		uiCanvas.get_node("PausePanel").visible = get_tree().paused
	if armyBuilder:
		if Input.is_action_just_pressed("move_right"):
			selectedArmyNo[1] += 1
			if selectedArmyNo[1] >= len(unitList[selectedArmyNo[0]]):
				selectedArmyNo[1] = 0
			selectedUnit = unitList[selectedArmyNo[0]][selectedArmyNo[1]]
			updateScreen()
		
		if Input.is_action_just_pressed("move_left"):
			selectedArmyNo[1] -= 1
			if selectedArmyNo[1] < 0:
				selectedArmyNo[1] = len(unitList[selectedArmyNo[0]]) - 1
			selectedUnit = unitList[selectedArmyNo[0]][selectedArmyNo[1]]
			updateScreen()
		for i in range(10):
			if Input.is_action_just_pressed(["key1","key2","key3","key4","key5","key6","key7","key8","key9","key0"][i]):
				if i < len(unitList):
					selectedArmyNo = [i,0]
				selectedUnit = unitList[selectedArmyNo[0]][selectedArmyNo[1]]
				updateScreen()
func calcEndTurn(firstEnd):
	if firstEnd:
		if OnlineHandler.players[OnlineHandler.playerId].team == currentTurn[0]:
			hideGame()
			return false
	if currentTurn[1]:
		#currentTurn[0] = 1 - currentTurn[0]
		currentTurn[1] = false
		var saveData = generateSaveData()
		saveData["isMultiplayer"] = true
		OnlineHandler.onlineLoad.rpc(saveData)
		if currentTurn[0] == 0:
			pass
		hideGame()
		return false
	return true

func endTurn(firstEnd = false, skipCalc = false):
	if not skipCalc:
		if isMultiplayer:
			if not calcEndTurn(firstEnd):
				return
	selectedAction = null
	if currentTurn[1]:
		selectedUnit = null
		currentTurn[1] = false
	else:
		if not firstEnd:
			if currentTurn[0] == 1:
				if armyBuilder:
					armyBuilder = false
				else:
					turnNo += 1
		if armyBuilder:
			selectedArmyNo = [0,0]
			selectedUnit = unitList[selectedArmyNo[0]][selectedArmyNo[1]]
		else:
			selectedUnit = null
		currentTurn[0] = 1 - currentTurn[0]
		currentTurn[1] = true
		for i in unitControl.get_children():
			if i.unitTeam == currentTurn[0]:
				i.startturnStatus()
		for i in unitControl.get_children():
			if i.unitTeam == currentTurn[0]:
				i.startturn()
		for i in unitControl.get_children():
			if i.unitTeam == currentTurn[0]:
				i.startturnStatus(true)
	updateScreen()
	
func hideGame():
	unitControl.hide()
	tileControl.hide()
	uiCanvas.hide()

func updateScreen():
	#var time = Time.get_ticks_usec()
	armyCosts = [0,0]
	for i in range(len(lightGrid)):
		lightGrid[i] = false
	if armyBuilder:
		updateScreenArmyBuilder()
	for i in unitControl.get_children():
		i.preUpdateScreen()
	for i in unitControl.get_children():
		i.updateScreen()
	for i in tileControl.get_children():
		i.updateScreen()
	for i in unitControl.get_children():
		i.postUpdateScreen()
	if not armyBuilder:
		if armyHighestCosts == null:
			armyHighestCosts = armyCosts
	uiCanvas.updateUI()
	#print("Update Screen took " + str((Time.get_ticks_usec() - time) * 0.001) + " milliseconds.")


func _on_button_pressed() -> void:
	endTurn()

func massSpawnUnits():
	var unitX = -1
	var unitY = 0
	for i in DirAccess.get_files_at("res://Nodes/Units"):
		if i.right(5) != ".tscn":
			continue
		
		unitX += 1
		for a in range(2):
			if not spawnUnitsRed:
				if a == 0:
					continue
			if not spawnUnitsBlue:
				if a == 1:
					continue
			
			if unitX >= gridWidth:
				unitX = 0
				unitY += 1
			spawnUnit(i,unitX,unitY + (a * 3),a)

func updateScreenArmyBuilder():
	armyCosts = [0,0]
	if not currentTurn[1]:
		return
	for y in range(gridHeight):
		for x in range(gridWidth):
			if armyGrid[y * gridWidth + x] == currentTurn[0]:
				lightGrid[y * gridWidth + x] = true

func spawnUnit(unitPath,unitX,unitY,unitTeam, summon = false):
	if unitPath.right(5) != ".tscn":
			unitPath += ".tscn"
	var spawnUnitNode = load("res://Nodes/Units/" + unitPath).instantiate()
	spawnUnitNode.gridX = unitX
	spawnUnitNode.gridY = unitY
	spawnUnitNode.unitTeam = unitTeam
	if summon:
		spawnUnitNode.addStatus("summon",null)
	unitControl.add_child(spawnUnitNode)
	spawnUnitNode.setupUnit()
