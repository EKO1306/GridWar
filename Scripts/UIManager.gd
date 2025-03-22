extends CanvasLayer

@onready var main = get_parent().get_parent()

@onready var uiLowerPanel = get_node("LowerPanel") as Panel
@onready var uiUpperPanel = get_node("UpperPanel") as Panel

@onready var uiNameLabel = uiLowerPanel.get_node("NamePanel/NamePanel/Label") as RichTextLabel

@onready var uiStatsPanel = uiLowerPanel.get_node("StatsPanel/PanelStatsCore") as Panel
@onready var uiStatsHealthBar = uiStatsPanel.get_node("BarHealth") as TextureProgressBar
@onready var uiStatsMovementBar = uiStatsPanel.get_node("BarMovement") as TextureProgressBar
@onready var uiStatsActionBar = uiStatsPanel.get_node("BarAction") as TextureProgressBar
@onready var uiStatsCostLabel = uiStatsPanel.get_node("LabelCost") as RichTextLabel

@onready var uiTraitPanels = uiLowerPanel.get_node("StatsPanel/Traits")
@onready var uiPanelActions = uiLowerPanel.get_node("ActionPanels")
@onready var uiPanelStatus = uiLowerPanel.get_node("NamePanel/StatusPanels")

@export var styleDark = Theme.new() as Theme
@export var styleLight = Theme.new() as Theme
@export var styleUpperDark = Theme.new() as Theme
@export var styleUpperLight = Theme.new() as Theme

@onready var uiPlayerText = uiUpperPanel.get_node("PlayerText") as RichTextLabel
@onready var uiRedScore = uiUpperPanel.get_node("RedScore") as RichTextLabel
@onready var uiBlueScore = uiUpperPanel.get_node("BlueScore") as RichTextLabel
@onready var uiEndTurnButton = uiUpperPanel.get_node("Button") as Button
var endTurnWarning = 0
var endTurnWarningType = 0

var tooltip
@onready var mouseNode = get_node("MouseNode") as Control

func _ready() -> void:
	uiLowerPanel.visible = false

func _process(delta: float) -> void:
	mouseNode.global_position = get_viewport().get_mouse_position()
	for i in mouseNode.get_children():
		var distanceOverEdge
		var viewportSize = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),ProjectSettings.get_setting("display/window/size/viewport_height"))
		i.position = Vector2.ZERO
		i.position.x += 4
		distanceOverEdge = (i.global_position.y + i.size.y) - (viewportSize.y)
		if distanceOverEdge > 0:
			i.position.y -= distanceOverEdge
		distanceOverEdge = (i.global_position.x + i.size.x) - (viewportSize.x)
		if distanceOverEdge > 0:
			i.position.x -= distanceOverEdge
	
	if endTurnWarning > 0:
		endTurnWarning -= delta
		if endTurnWarning <= 0:
			uiEndTurnButton.text = "End\nTurn"

func updateUI():
	var _time = Time.get_ticks_usec()
	var unit = main.selectedUnit
	if unit == null:
		uiLowerPanel.visible = false
	else:
		uiLowerPanel.visible = true
		if main.armyBuilder:
			unit = load("res://Nodes/Units/" + unit + ".tscn").instantiate()
		updateStats(unit)
		updateTraits(unit)
		updateActions(unit)
		updateStatus(unit)
		if (unit.unitTeam == 0 and not main.armyBuilder) or (main.currentTurn[0] == 0 and main.armyBuilder):
			styleDark.get_stylebox("panel", "Panel").bg_color = Color(0.286,0.031,0.129)
			styleLight.get_stylebox("panel", "Panel").bg_color = Color(0.557,0.141,0.263)
		else:
			styleDark.get_stylebox("panel", "Panel").bg_color = Color(0.031,0.129,0.286)
			styleLight.get_stylebox("panel", "Panel").bg_color = Color(0.141,0.263,0.557)
	updateUpperPanel()
	#print("Update UI took " + str(Time.get_ticks_usec() - time))

func updateStats(unit):
	uiNameLabel.text = "[center]" + unit.statName
	if main.armyBuilder:
		unit.statHealth = unit.statMaxHealth
		unit.statMovement = unit.statMaxMovement
		unit.statActions = unit.statMaxActions
	uiStatsHealthBar.value = round((unit.statHealth/float(unit.statMaxHealth))*80)
	uiStatsHealthBar.get_node("Label").text = "[center]" + str(unit.statHealth) + "/" + str(unit.statMaxHealth)
	uiStatsMovementBar.value = round((unit.statMovement/float(unit.statMaxMovement))*80)
	uiStatsMovementBar.get_node("Label").text = "[center]" + str(unit.statMovement) + "/" + str(unit.statMaxMovement)
	uiStatsActionBar.value = round((unit.statActions/float(unit.statMaxActions))*80)
	uiStatsActionBar.get_node("Label").text = "[center]" + str(unit.statActions) + "/" + str(unit.statMaxActions)
	uiStatsCostLabel.text = "[center]" + str(unit.statCost)

func updateTraits(unit):
	for i in uiTraitPanels.get_children():
		i.queue_free()
	for i in range(len(unit.statTraits)):
		drawTrait(unit.statTraits[i], uiTraitPanels, Vector2((50*i),0), "trait")
		
func updateActions(unit):
	for i in uiPanelActions.get_children():
		i.queue_free()
	var traitPanel
	var statActionValue
	for i in range(len(unit.statActionList)):
		statActionValue = unit.statActionList[i]
		traitPanel = preload("res://Nodes/UI/panel_action.tscn").instantiate()
		traitPanel.get_node("PanelTitle/Name").text = "[center]" + statActionValue.name
		traitPanel.get_node("PanelTitle/IconAction/Label").text = "[center]" + str(statActionValue.actions)
		traitPanel.actionNo = i
		traitPanel.main = main
		traitPanel.theme = styleLight
		traitPanel.get_node("PanelTitle").theme = styleDark
		if statActionValue.range.x <= 1:
			traitPanel.get_node("PanelTitle/IconRange/Label").text = "[center]" + str(statActionValue.range.y)
		else:
			traitPanel.get_node("PanelTitle/IconRange/Label").text = "[center]" + str(statActionValue.range.x) + "-" + str(statActionValue.range.y)
		if main.selectedAction == i:
			traitPanel.modulate = Color(2,2,2)
		elif not unit.checkActionValid(statActionValue,i):
			traitPanel.modulate = Color(0.5,0.5,0.5)
		uiPanelActions.add_child(traitPanel)
		var uiPanelActionTraits = traitPanel.get_node("TraitPanels")
		if i % 2 == 0:
			@warning_ignore("integer_division")
			traitPanel.position = Vector2((i/2) * 210,0)
		else:
			@warning_ignore("integer_division")
			traitPanel.position = Vector2((i/2) * 210,92)
		for a in uiPanelActionTraits.get_children():
			a.queue_free()
		for a in range(len(statActionValue.traits)):
			drawTrait(statActionValue.traits[a], uiPanelActionTraits, Vector2(a * 50,0),"action")

func drawTrait(traitValue, addedNode, traitPosition, traitType):
	var traitPanel = preload("res://Nodes/UI/panel_trait.tscn").instantiate()
	var traitTexture
	if traitType == "trait":
		traitTexture = load("res://Images/Icons/Traits/" + str(traitValue[0]) + ".png")
	elif traitType == "action":
		traitTexture = load("res://Images/Icons/ActionTraits/" + str(traitValue[0]) + ".png")
	elif traitType == "status":
		traitTexture = load("res://Images/Icons/Status/" + str(traitValue[0]) + ".png")
	if traitTexture != null:
		traitPanel.texture = traitTexture
	addedNode.add_child(traitPanel)
	traitPanel.position = traitPosition
	var traitTooltipList
	if traitType == "trait":
		traitTooltipList = main.traitTooltipList.get(traitValue[0])
	elif traitType == "action":
		traitTooltipList = main.actionTraitTooltipList.get(traitValue[0])
	elif traitType == "status":
		traitTooltipList = main.statusTooltipList.get(traitValue[0])
	if traitTooltipList != null:
		var tooltipFormat = {"s": "s stuff can go here"}
		var a = -2
		if traitType == "status":
			a = -3
		for i in traitValue:
			a += 1
			tooltipFormat[str(a)] = i
		traitPanel.tooltip = traitTooltipList.tooltip.format(tooltipFormat)
		if traitTooltipList.get("traitText") != null:
			traitPanel.get_node("Label").text = "[center]" + traitTooltipList.traitText.format(tooltipFormat)
	else:
		traitPanel.tooltip = "Error: No tooltip found."
		#if traitType == "status":
			#if len(traitValue) >= 3:
				#traitPanel.get_node("Label").text = "[center]" + str(traitValue[2])
		#else:
			#if len(traitValue) >= 2:
				#traitPanel.get_node("Label").text = "[center]" + str(traitValue[1])
	if traitType == "status":
		if traitValue[1] != null:
			traitPanel.get_node("Label2").text = "[center]" + str(traitValue[1])

func updateStatus(unit):
	for a in uiPanelStatus.get_children():
		a.queue_free()
	for a in range(len(unit.statusList)):
		drawTrait(unit.statusList[a], uiPanelStatus, Vector2(a * 50,0),"status")

func updateUpperPanel():
	uiRedScore.text = ""
	uiBlueScore.text = "[right]"
	if not main.armyBuilder:
		uiRedScore.text += str(ceil((main.armyCosts[0] / float(main.armyHighestCosts[0])) * 10) * 10) + "%"
		uiBlueScore.text += str(ceil((main.armyCosts[1] / float(main.armyHighestCosts[1])) * 10) * 10) + "%"
	if main.currentTurn[1]:
		if main.armyBuilder:
			if main.currentTurn[0] == 0:
				uiRedScore.text += str(main.armyCosts[0])
				if main.doArmyCostLimit:
					uiRedScore.text += "/" + str(main.armyCostLimit)
			else:
				uiBlueScore.text += str(main.armyCosts[1])
				if main.doArmyCostLimit:
					uiBlueScore.text += "/" + str(main.armyCostLimit)
		uiPlayerText.text = "[center]" + str(["RED","BLUE"][main.currentTurn[0]] + " TURN")
		if main.currentTurn[0] == 0:
			styleUpperDark.get_stylebox("panel", "Panel").bg_color = Color(0.286,0.031,0.129)
			styleUpperLight.get_stylebox("panel", "Panel").bg_color = Color(0.557,0.141,0.263)
		else:
			styleUpperDark.get_stylebox("panel", "Panel").bg_color = Color(0.031,0.129,0.286)
			styleUpperLight.get_stylebox("panel", "Panel").bg_color = Color(0.141,0.263,0.557)
	else:
		uiPlayerText.text = "[center]" + str(["BLUE","RED"][main.currentTurn[0]] + " TURN NEXT")
		if main.currentTurn[0] == 1:
			styleUpperDark.get_stylebox("panel", "Panel").bg_color = Color(0.286,0.031,0.129)
			styleUpperLight.get_stylebox("panel", "Panel").bg_color = Color(0.557,0.141,0.263)
		else:
			styleUpperDark.get_stylebox("panel", "Panel").bg_color = Color(0.031,0.129,0.286)
			styleUpperLight.get_stylebox("panel", "Panel").bg_color = Color(0.141,0.263,0.557)

func addTooltip(text):
	removeTooltip()
	var tooltipNode = preload("res://Nodes/UI/tooltip.tscn").instantiate()
	tooltipNode.text = text
	mouseNode.add_child(tooltipNode)

func removeTooltip():
	for i in mouseNode.get_children():
		i.queue_free()


func _on_end_turn_button_pressed() -> void:
	if main.currentTurn[1]:
		if main.armyBuilder:
			if main.armyCosts[main.currentTurn[0]] == 0:
				endTurnWarning = 1
				endTurnWarningType = 1
				uiEndTurnButton.text = "No\nUnits!"
				return
			if main.doArmyCostLimit:
				if main.armyCosts[main.currentTurn[0]] > main.armyCostLimit:
					endTurnWarning = 1
					endTurnWarningType = 1
					uiEndTurnButton.text = "Over\nBudget!"
					return
	if (endTurnWarning > 0 and endTurnWarningType == 0) or not(main.currentTurn[1]):
		endTurnWarning = 0
		endTurnWarningType = 0
		uiEndTurnButton.text = "End\nTurn"
		main.endTurn()
		return
	endTurnWarning = 1
	endTurnWarningType = 0
	uiEndTurnButton.text = "Are You\nSure?"
