extends Button

var mapData
var buttonType
@onready var ui = get_parent().get_parent().get_parent().get_parent().get_parent()

func _ready() -> void:
	if buttonType == "Play":
		text = "Play"
	if buttonType == "Editor":
		text = "Edit"


func _pressed() -> void:
	if buttonType == "Play":
		get_tree().current_scene.changeScene("res://Scenes/main.tscn", mapData)
	if buttonType == "Editor":
		get_tree().current_scene.changeScene("res://Scenes/map_editor.tscn", mapData)
