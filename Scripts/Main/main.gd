extends "main_functions.gd"

var selectedUnit
var selectedAction
@export var spawnUnitsRed = false
@export var spawnUnitsBlue = false
var armyCosts = [0,0]

@export var armyBuilder = true
var selectedArmyNo = [0,0]
var armyGrid = []
@export var doArmyCostLimit = true
@export var armyCostLimit = 5000

var mapEditor = false

@onready var uiCanvas = $Camera2D/CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
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
		armyHighestCosts = get_parent().scenePassover.armyHighestCosts
		updateScreen()
	else:
		massSpawnUnits()
		endTurn()

func loadUnits(units):
	for unit in units:
		var unitNode = load(unit.pathName).instantiate()
		unitNode.statName = unit.name
		unitNode.statMaxHealth = unit.maxHealth
		unitNode.statHealth = unit.health
		unitNode.statMaxMovement = unit.maxMovement
		unitNode.statMovement = unit.movement
		unitNode.statMaxActions = unit.maxActions
		unitNode.statActions = unit.actions
		print(unitNode.statActions,unit.actions)
		unitNode.statCost = unit.cost
		unitNode.statTraits = unit.traitsList
		#unitNode.statActionList = unit.actionList
		unitNode.statusList = unit.statusList
	
		unitNode.gridX = unit.gridX
		unitNode.gridY = unit.gridY
		unitNode.unitTeam = unit.team
		unitControl.add_child(unitNode)
	
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

func endTurn():
	selectedAction = null
	if currentTurn[1]:
		selectedUnit = null
		if currentTurn[0] == 1 and armyBuilder:
			armyBuilder = false
			armyHighestCosts = armyCosts
		currentTurn[1] = false
	else:
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
	updateScreen()

func updateScreen():
	armyCosts = [0,0]
	for i in range(len(lightGrid)):
		lightGrid[i] = false
	if armyBuilder:
		updateScreenArmyBuilder()
	for i in unitControl.get_children():
		i.updateScreen()
	for i in tileControl.get_children():
		i.updateScreen()
	for i in unitControl.get_children():
		i.postUpdateScreen()
	if armyHighestCosts == null:
		armyHighestCosts = armyCosts
	uiCanvas.updateUI()


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

func spawnUnit(unitPath,unitX,unitY,unitTeam):
	var spawnUnitNode = load("res://Nodes/Units/" + unitPath).instantiate()
	spawnUnitNode.gridX = unitX
	spawnUnitNode.gridY = unitY
	spawnUnitNode.unitTeam = unitTeam
	unitControl.add_child(spawnUnitNode)
	spawnUnitNode.setupUnit()
