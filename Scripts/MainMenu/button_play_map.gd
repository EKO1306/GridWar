extends Button

var mapData
var buttonType
@onready var ui = get_tree().get_current_scene().get_child(0).get_node("MainMenuUI")

func _ready() -> void:
	if buttonType == "Editor":
		text = "Edit"

func _pressed() -> void:
	if buttonType == "Play":
		ui.chosenMap = mapData
	if buttonType == "Editor":
		get_tree().get_current_scene().changeScene("res://Scenes/map_editor.tscn", mapData)
