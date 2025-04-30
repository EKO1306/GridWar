extends Panel

@onready var winningTeam = get_tree().get_current_scene().scenePassover.get("winningTeam")
@onready var isMultiplayer = get_tree().get_current_scene().scenePassover.get("isMultiplayer")

func _ready() -> void:
	print(isMultiplayer)
	$NinePatchRect/RichTextLabel.text = ["RED","BLUE","Nobody"][winningTeam] + " did a win"
	print("yoyo")


func _on_back_to_menu_button_pressed() -> void:
	if isMultiplayer:
		get_tree().get_current_scene().changeScene("res://Scenes/main_menu.tscn", {"multiplayerPanels": true})
	else:
		get_tree().get_current_scene().changeScene("res://Scenes/main_menu.tscn")
