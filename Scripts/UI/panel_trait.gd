extends TextureRect

var tooltip = "Bro, huhhhh"

var isMouseOver = false
@onready var main = get_tree().get_current_scene().main

func _on_tree_exiting() -> void:
	if isMouseOver:
		main.uiCanvas.removeTooltip()


func _on_mouse_entered() -> void:
	isMouseOver = true
	main.uiCanvas.addTooltip(tooltip)


func _on_mouse_exited() -> void:
	isMouseOver = false
	main.uiCanvas.removeTooltip()
