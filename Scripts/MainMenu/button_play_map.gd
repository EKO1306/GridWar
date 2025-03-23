extends Button

var mapData
var buttonType
@onready var ui = get_parent().get_parent().get_parent().get_parent().get_parent()


func _pressed() -> void:
	if buttonType == "Play":
		ui.chosenMap = mapData
	if buttonType == "Editor":
		ui.chosenMap = mapData
