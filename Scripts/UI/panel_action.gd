extends Panel

var isMouseOver = false
var actionNo

var main

func _process(delta: float) -> void:
	if main.armyBuilder:
		return
	if main.selectedUnit == null:
		return
	if main.currentTurn[0] != main.selectedUnit.unitTeam:
		return
	var mousePos = get_global_mouse_position() - global_position
	var inBox = true
	if mousePos.x < 0:
		inBox = false
	elif mousePos.y < 0:
		inBox = false
	elif mousePos.x > 206:
		inBox = false
	elif mousePos.y > 90:
		inBox = false
	if inBox:
		if main.armyBuilder:
			return
		if not isMouseOver:
			isMouseOver = true
			modulate += Color(0.2,0.2,0.2)
	else:
		if isMouseOver:
			isMouseOver = false
			modulate -= Color(0.2,0.2,0.2)

func _on_gui_input(event: InputEvent) -> void:
	if isMouseOver:
		if event is InputEventMouseButton and event.button_index == 1:
			if event.button_mask == 1:
				main.selectedUnit.selectAction(actionNo)
