extends Area2D

@export_category("Unit Stats")
@export var statName = ""
@export var statMaxHealth = 100
@onready var statHealth = statMaxHealth
@export var statMaxMovement = 3
@onready var statMovement = statMaxMovement
@export var statMaxActions = 1
@onready var statActions = statMaxActions
@export var statCost = 100
@export var statTraits = []
@export var statActionList: Array[Dictionary] = [{"name": "NAME", "actions": 1, "range": Vector2(0,1), "traits": [["damage",80],["melee"]]}]

@export_category("Unit Variables")
@export var gridX = 0
@export var gridY = 0
@export var unitTeam = 0

var rng = RandomNumberGenerator.new()
var isVisible = false
var exists = true

var statusList = []

@onready var main = get_parent().get_parent()
@onready var uiCanvas = main.get_node("Camera2D/CanvasLayer")

@onready var nodeHealthBar = get_node_or_null("HealthBar") as TextureProgressBar
@onready var nodeAnimationPlayer = get_node("AnimationPlayer") as AnimationPlayer

var animationMovementBuffer = []
var movementOffset = Vector2.ZERO

var hasMoved = false
var hasActed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprites.material = ShaderMaterial.new()
	$Sprites.material.shader = preload("res://Shaders/unitOutline.gdshader")
	$Sprites.material.set_shader_parameter("line_thickness", 4)
	$AnimationPlayer.play("Idle")
	$AnimationPlayer.speed_scale = rng.randf_range(0.9,1.1)
	if unitTeam == 0:
		$Sprites.material.set_shader_parameter("line_color",Color(1,0,0))
		$Sprites.scale = Vector2(1,1)
	elif unitTeam == 1:
		$Sprites.material.set_shader_parameter("line_color",Color(0,0,1))
		$Sprites.scale = Vector2(-1,1)
	for chargeTrait in hasTrait("charge"):
		addStatus("charge",null,[chargeTrait[0][1]])
	
func _process(delta):
	if main.armyBuilder:
		updatePosition(delta)
		return
	if main.selectedUnit == self:
		var moved = false
		$Sprites.modulate = Color(100,100,100,1)
		$Sprites.self_modulate = Color(0.01,0.01,0.01,1)
		if main.currentTurn[0] == unitTeam:
			if Input.is_action_just_pressed("move_right"):
				if moveToXY(gridX+1,gridY,true):
					moved = true
			if Input.is_action_just_pressed("move_left"):
				if moveToXY(gridX-1,gridY,true):
					moved = true
			if Input.is_action_just_pressed("move_up"):
				if moveToXY(gridX,gridY-1,true):
					moved = true
			if Input.is_action_just_pressed("move_down"):
				if moveToXY(gridX,gridY+1,true):
					moved = true
			if moved:
				main.updateScreen()
			else:
				for i in range(10):
					isActionPressed(["key1","key2","key3","key4","key5","key6","key7","key8","key9","key0"][i],i)
	else:
		$Sprites.modulate = Color(1,1,1,1)
		$Sprites.self_modulate = Color(1,1,1,1)
	updatePosition(delta)

func _input_event(_viewport,_event,_shapeidx):
	if not isVisible or main.armyBuilder:
		return
	if Input.is_action_just_pressed("left_click"):
		if main.selectedAction == null:
			if main.selectedUnit == self:
				main.selectedUnit = null
			else:
				main.selectedUnit = self
			if main.selectedAction != null:
				main.selectedAction = null
		else:
			main.selectedUnit.calcAction(self)
			main.updateScreen()
		main.uiCanvas.updateUI()

func updatePosition(delta):
	z_index = gridY * 2 + 1
	if len(animationMovementBuffer) > 0:
		movementOffset = movementOffset.move_toward(animationMovementBuffer[0],delta*statMaxMovement*16)
		if movementOffset.distance_to(animationMovementBuffer[0]) == 0:
			animationMovementBuffer.pop_at(0)
	global_position.x = (gridX*24)-12
	global_position.y = (gridY*24)-12
	$Sprites.position = movementOffset + Vector2(12,12)
	var heightOffset = main.tileGrid[gridX+(gridY*main.gridWidth)].height * 4
	global_position.y -= heightOffset
	if not movementOffset.is_zero_approx():
		var spriteGridPosition = floor(($Sprites.global_position + Vector2(12,12)) / 24)
		var spriteTile = main.tileGrid[spriteGridPosition.x+(spriteGridPosition.y*main.gridWidth)]
		z_index = spriteGridPosition.y * 2 + 1
		$Sprites.position.y -= spriteTile.height * 4
		$Sprites.position.y += heightOffset

func moveToXY(x,y,spendMovement):
	var currentTile = main.getTileAtXY(gridX,gridY)
	var targetTile = main.getTileAtXY(x,y)
	if x > gridX:
		$Sprites.scale = Vector2(1,1)
	if x < gridX:
		$Sprites.scale = Vector2(-1,1)
	
	if targetTile == null:
		return
	if targetTile.type == 1:
		return
	if main.getUnitAtXY(x,y) != null:
		return
	if abs(targetTile.height - currentTile.height) > 1:
		if targetTile.type == 4:
			return moveToXY(gridX + (gridX-x)*-2,gridY + (gridY-y)*-2,spendMovement)
		return
	if spendMovement:
		var distanceToTile = abs(x-gridX) + abs(y-gridY)
		if targetTile.type == 2 or targetTile.type == 3:
			distanceToTile += 0.5
			for hasMounted in hasTrait("mounted"):
				distanceToTile += 0.5
		if distanceToTile > statMovement:
			return
		statMovement -= distanceToTile
	for i in range(len(animationMovementBuffer)):
		animationMovementBuffer[i] -= Vector2(x-gridX,y-gridY) * 24
	animationMovementBuffer.append(Vector2.ZERO)
	movementOffset -= Vector2(x-gridX,y-gridY) * 24
	hasMoved = true
	gridX = x
	gridY = y
	return true

func startturn():
	statMovement = statMaxMovement
	statActions = statMaxActions
	
	hasMoved = false
	hasActed = false
	
	for hasShield in hasTrait("shield"): #Grant block if the unit has shield
		addStatus("block",1,[hasShield[0][1]])
	
	for hasShieldwall in hasTrait("shieldwall"): #Grant block for each adjacent ally with the shield trait.
		var finalBlock = 0
		var adjacentUnits = getUnitsInArea(gridX,gridY,1,self,unitTeam)   
		for i in adjacentUnits:
			for hasShield in i.hasTrait("shield"):
				finalBlock += hasShield[0][1]
		if finalBlock > 0:
			addStatus("block",1,[finalBlock])
	
	for hasBurning in hasStatus("burning"):
		damage(hasBurning[0][2])
	for hasPoisoned in hasStatus("poisoned"):
		changeHealth(-hasPoisoned[0][2])


func startturnStatus():
	var removedStatus = []
	for i in range(len(statusList)):
		
		if statusList[i][1] == null:
			continue
		statusList[i][1] -= 1
		if statusList[i][1] <= 0:
			removedStatus.append(i - len(removedStatus))
	for i in removedStatus:
		removeStatus(i)

func updateGrid():
	pass

func updateScreen():
	if not exists:
		return
	main.armyCosts[unitTeam] += statCost
	if main.armyBuilder:
		monitoring = false
		return
	monitoring = true
	if main.currentTurn[1]:
		if main.currentTurn[0] == unitTeam:
			if main.selectedAction == null:
				checkVisionArea()
			elif main.selectedUnit == self:
				checkVisionArea(statActionList[main.selectedAction])

func postUpdateScreen():
	isVisible = main.lightGrid[gridY * main.gridWidth + gridX]
	if isVisible:
		modulate.a = 1
		if nodeHealthBar != null:
			nodeHealthBar.value = (statHealth/float(statMaxHealth)) * 100
			nodeHealthBar.size.x = 8 + clamp(floor(((log(statMaxHealth/25))/log(1.5))/2)*2,6,32)
			nodeHealthBar.position.x = 12 - (nodeHealthBar.size.x / 2)
			var blockTotal = 0
			for hasBlock in hasStatus("block"):
				blockTotal += hasBlock[0][2]
			nodeHealthBar.get_node("ShieldBar").value = (blockTotal/float(statMaxHealth)) * 100
			nodeHealthBar.get_node("Action").position.x = nodeHealthBar.size.x - 5
			if unitTeam == main.currentTurn[0]:
				nodeHealthBar.get_node("Movement").modulate.a = 1
				nodeHealthBar.get_node("Action").modulate.a = 1
				if statMovement <= 0:
					nodeHealthBar.get_node("Movement").self_modulate.a = 0
				elif not hasMoved:
					nodeHealthBar.get_node("Movement").self_modulate.a = 1
				else:
					nodeHealthBar.get_node("Movement").self_modulate.a = 0.6
				if statActions <= 0:
					nodeHealthBar.get_node("Action").self_modulate.a = 0
				elif not hasActed:
					nodeHealthBar.get_node("Action").self_modulate.a = 1
				else:
					nodeHealthBar.get_node("Action").self_modulate.a = 0.6
			else:
				nodeHealthBar.get_node("Movement").modulate.a = 0
				nodeHealthBar.get_node("Action").modulate.a = 0
	else:
		modulate.a = 0

func checkVisionArea(action = null):
	var _time = Time.get_ticks_usec()
	var directionVector
	var directionVectors = []
	for y in range(-10,10):
		for x in range(-10,10):
			if x == 0:
				if y == 0:
					continue
			directionVector = Vector2(x/10.0,y/10.0).normalized()
			if directionVectors.count(directionVector) != 0:
				continue
			directionVectors.append(directionVector)
			drawVisionLine(gridX,gridY,directionVector, action)
	#print(Time.get_ticks_usec() - time)

func drawVisionLine(lineX,lineY,lineVelocity, action):
	var lineLength = 0
	
	var linePos
	var lineTile
	var lineBuffer = Vector2(0,0)
	
	var lineBaseHeight = main.tileGrid[gridY * main.gridWidth + lineX].height
	var lineMinHeight = 0
	
	var lightTile
	var tileEffectiveHeight
	
	var actionLineMixRange
	var actionLineMaxRange
	
	var foliageRange = 1
	for hasEagleEye in hasTrait("eagleEye"):
		foliageRange += hasEagleEye[0][1]
	
	if action != null:
		actionLineMixRange = action.range[0]
		actionLineMaxRange = action.range[1]
	
	while true:
		if lineLength >= 20:
			break
		if action != null: #End the line if it has exceeded the action range.
			if lineLength > actionLineMaxRange:
				break
		
		linePos = lineY * main.gridWidth + lineX
		lineTile = main.tileGrid[linePos]
		tileEffectiveHeight = lineTile.height
		
		if lineTile.type == 3: #Trees are considered 2 higher for vision, unless you're inside it.
			if lineLength > 0:
				tileEffectiveHeight += 2
		
		if tileEffectiveHeight > lineBaseHeight: # If a wall higher than the unit blocks vision, anything 2 height or more below it isn't visible.
			if lineTile.type != 4:
				lineMinHeight = max(lineMinHeight,tileEffectiveHeight)
		
		lightTile = true
		if tileEffectiveHeight < lineMinHeight - 1: #You cannot see tiles more than 1 below where you are, unless on edge.
			lightTile = false
		if lineLength > foliageRange: #You cannot see into bushes and trees, unless you are adjacent to them.
			if lineTile.type == 2 or lineTile.type == 3:
				var lineUnit = main.getUnitAtXY(lineX,lineY)
				if lineUnit != null:
					if (
					lineUnit.hasTrait("mounted").is_empty()
					and lineUnit.hasStatus("burning").is_empty()
					and lineUnit.hasStatus("exposed").is_empty()
					): #Burning and mounted units can't hide.
						lightTile = false
				else:
					lightTile = false
				
		if action != null:
			if lineLength < actionLineMixRange:
				lightTile = false
		
		if lightTile:
			main.lightGrid[linePos] = true
		
		if tileEffectiveHeight >= lineBaseHeight + 2: # If the tile is 2 or more height above the unit, you can only see one tile in, and the line ends.
			if lineTile.type != 4:
				break
		
		lineBuffer += lineVelocity
		while lineBuffer.x >= 1:
			lineX += 1
			lineLength += 1
			lineBuffer.x -= 1
		while lineBuffer.x <= -1:
			lineX -= 1
			lineLength += 1
			lineBuffer.x += 1
		while lineBuffer.y >= 1:
			lineY += 1
			lineLength += 1
			lineBuffer.y -= 1
		while lineBuffer.y <= -1:
			lineY -= 1
			lineLength += 1
			lineBuffer.y += 1
		
		if lineX >= main.gridWidth:
			#Right border
			break
		if lineY >= main.gridHeight:
			#Top border"
			break
		if lineX < 0:
			#"Left border"
			break
		if lineY < 0:
			#"Bottom border"
			break#

func isActionPressed(key,action):
	if Input.is_action_just_pressed(key):
		if len(statActionList) > action:
			selectAction(action)
	

func selectAction(action):
	if main.selectedAction == action:
		main.selectedAction = null
		main.updateScreen()
	else:
		if checkActionValid(statActionList[action], action):
			main.selectedAction = action
			if not hasTrait("selfTarget",action).is_empty():
				calcAction(self)
				main.selectedAction = null
			main.updateScreen()

func calcAction(targetUnit):
	var time = Time.get_ticks_usec()
	var actionNo = main.selectedAction
	var currentAction = statActionList[actionNo]
	var isTargetDead = false
	var didActionTrigger = false
	
	if not checkActionValid(currentAction, actionNo):
		return
	
	print("I hit " + targetUnit.name + " at " + str(Vector2(targetUnit.gridX,targetUnit.gridY)))
	hasActed = true
	
	for hasReload in hasTrait("reload", actionNo): #Tick up Ammo from reload
		for actions in range(len(statActionList)):
			for hasAmmo in hasTrait("ammo",actions):
				if hasAmmo[0][1] < hasAmmo[0][2]:
					statActionList[actions].traits[hasAmmo[1]][1] += hasReload[0][1]
					didActionTrigger = true
	
	for hasHeal in hasTrait("heal", actionNo): #Heals target from heal trait
		if targetUnit.hasTrait("mechanical").is_empty(): #Mechanical Units cannot be healed.
			targetUnit.changeHealth(hasHeal[0][1])
			didActionTrigger = true
	for hasBurn in hasTrait("burn", actionNo): #Inficts burning from burn trait
		targetUnit.addStatus("burning", 4, [hasBurn[0][1]])
		didActionTrigger = true
	for hasPoison in hasTrait("poison", actionNo): #Inficts poisoned from poison trait
		targetUnit.addStatus("poisoned", 4, [hasPoison[0][1]])
		didActionTrigger = true
	for hasExpose in hasTrait("expose", actionNo): #Inficts exposed from expose trait
		targetUnit.addStatus("exposed", hasExpose[0][1], [])
		didActionTrigger = true
	
	for hasUrsuanaYaalCommand in hasTrait("ursuanaYaalCommand", actionNo): #Gives UrsuanaYaalCommand status on mounted within 2 tiles.
		for unit in getUnitsInArea(gridX,gridY,2,null,unitTeam):
			if not unit.hasTrait("mounted").is_empty():
				unit.addStatus("ursuanaYaalCommand", 2, [])
				didActionTrigger = true
	
	for hasDamage in hasTrait("damage", actionNo): #Deals damage equal to damage trait
		if not isTargetDead:
			if targetUnit.damage(hasDamage[0][1], self, actionNo): #Did the target die from the damage?
				isTargetDead = true
			didActionTrigger = true
	
	if isTargetDead:
		for hasRampage in hasTrait("rampage", actionNo): #If the target died, gain actions if rampage trait
			statActions += hasRampage[0][1]
	
	if didActionTrigger:
		nodeAnimationPlayer.play("action" + str(actionNo))
		while true: #If the unit has the charge status, remove it.
			var hasCharge = hasStatus("charge")
			if hasCharge.is_empty():
				break
			removeStatus(hasCharge[0][1])
		
		for hasUsePerTurn in hasTrait("usePerTurn", actionNo): #Tick down Use Per Turn
			statActionList[actionNo].traits[hasUsePerTurn[1]][1] -= 1
		
		for hasUse in hasTrait("use", actionNo): #Tick down Use
			statActionList[actionNo].traits[hasUse[1]][1] -= 1
		
		for hasAmmo in hasTrait("ammo", actionNo): #Tick down Ammo
			statActionList[actionNo].traits[hasAmmo[1]][1] -= 1
	
		#Update Actions
		statActions -= currentAction.actions
		if statActions < currentAction.actions:
			if statActions <= 0:
				if hasTrait("vigilance").is_empty():
					statMovement = 0
	print("Action took " + str(Time.get_ticks_usec() - time) + " usec.")
	
	if not checkActionValid(currentAction, actionNo):
		main.selectedAction = null

func hasTrait(traitName, action = null):
	var varFoundTraits = []
	var a = -1
	if action == null:
		for i in statTraits:
			a += 1
			if i[0] == traitName:
				varFoundTraits.append([i,a])
	else:
		for i in statActionList[action].traits:
			a += 1
			if i[0] == traitName:
				varFoundTraits.append([i,a])
	return varFoundTraits

func hasStatus(statusName):
	var a = -1
	var varFoundStatus = []
	for i in statusList:
		a += 1
		if i[0] == statusName:
			varFoundStatus.append([i,a])
	return varFoundStatus

func calcDamage(dmg, includeAbsorb = false,unitSource = null, actionSource = null):
	if unitSource != null:
		for hasUrsuanaYaalCommandStatus in unitSource.hasStatus("ursuanaYaalCommand"):
			dmg *= 1.5
	
	for hasDefence in hasTrait("defence"): #Defence reduces damage taken.
		dmg -= hasDefence[0][1]
	
	return floor(dmg)

func damage(dmg,unitSource = null, actionSource = null):
	dmg = calcDamage(dmg, false, unitSource, actionSource)
	var statusBlock
	while true:
		statusBlock = hasStatus("block")
		if statusBlock.is_empty():
			break
		statusBlock = statusBlock[0]
		if dmg <= 0:
			break
		else:
			var blockTotal = statusBlock[0][2]
			statusList[statusBlock[1]][2] -= dmg
			if statusList[statusBlock[1]][2] <= 0:
				removeStatus(statusBlock[1])
			dmg -= blockTotal
	
	if dmg > 0:
		return changeHealth(-dmg)
	return false

func checkActionValid(action, actionNo):
	if statActions < action.actions:
		return false
	for hasUsePerTurn in hasTrait("usePerTurn", actionNo):
		if hasUsePerTurn[0][1] <= 0:
			return false
	for hasUse in hasTrait("use", actionNo):
		if hasUse[0][1] <= 0:
			return false
	for hasAmmo in hasTrait("ammo", actionNo):
		if hasAmmo[0][1] <= 0:
			return false
		
	return true

func addStatus(status, duration, variables = []):
	var statusExists = false
	var a = -1
	for i in statusList:
		a += 1
		if i[0] == status:
			if i[1] == duration:
				statusExists = true
				break
	if statusExists:
		for i in range(len(variables)):
			statusList[a][i+2] += variables[i]
	else:
		statusList.append([status,duration])
		for i in variables:
			statusList[-1].append(i)
	
	#Handle effects when status added
	if status == "charge":
		statMaxMovement += variables[0]
		statMovement += variables[0]
	if status == "ursuanaYaalCommand":
		statMaxMovement += 1
		statMovement += 1

func removeStatus(statusNo):
	var status = statusList[statusNo]
	statusList.pop_at(statusNo)
	
	#Handle effects when status removed
	if status[0] == "charge":
		statMaxMovement -= status[2]
	if status[0] == "ursuanaYaalCommand":
		statMaxMovement -= 1

func changeHealth(change):
	statHealth += change
	
	statHealth = min(statHealth,statMaxHealth)
		
	
	if statHealth <= 0:
		queue_free()
		exists = false
		return true
	else:
		return false

func getUnitsInArea(areaX,areaY,areaRadius,unitMask = null, teamMask = null):
	var unitList = []
	for i in main.unitControl.get_children():
		if not i.is_in_group("Unit"):
			continue
		if abs(areaX - i.gridX) + abs(areaY - i.gridY) > areaRadius:
			continue
		if unitMask != null:
			if unitMask == i:
				continue
		if teamMask != null:
			if teamMask != i.unitTeam:
				continue
		unitList.append(i)
	return unitList
