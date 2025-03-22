extends TextureRect

var tooltip = "Bro, huhhhh"

var isMouseOver = false
@onready var main = get_tree().get_current_scene().main

func _process(_delta: float) -> void:
	var mousePos = get_global_mouse_position() - global_position
	var inBox = true
	if mousePos.x < 0:
		inBox = false
	elif mousePos.y < 0:
		inBox = false
	elif mousePos.x > 48:
		inBox = false
	elif mousePos.y > 48:
		inBox = false
	if inBox:
		if len(main.uiCanvas.mouseNode.get_children()) == 0:
			isMouseOver = true
			main.uiCanvas.addTooltip(tooltip)
	else:
		if isMouseOver:
			isMouseOver = false
			main.uiCanvas.removeTooltip()

func _on_tree_exiting() -> void:
	main.uiCanvas.removeTooltip()
