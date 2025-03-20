extends Panel

var returnWarning = 0
var quitWarning = 0

@onready var main = get_tree().get_current_scene().get_child(0)

@onready var nodePausePanel = get_node("PausePanel")
@onready var nodeButtonReturn = nodePausePanel.get_node("VBoxContainer/ReturnButton")
@onready var nodeButtonQuit = nodePausePanel.get_node("VBoxContainer/QuitButton")
@onready var nodePlayerText = nodePausePanel.get_node("PlayerText")

func _process(delta: float) -> void:
	if returnWarning > 0:
		returnWarning -= delta
		if returnWarning <= 0:
			nodeButtonReturn.text = "Return to Menu"
	if quitWarning > 0:
		quitWarning -= delta
		if quitWarning <= 0:
			$PausePanel/VBoxContainer/QuitButton.text = "Quit Game"
	if main.currentTurn[1]:
		nodePlayerText.text = "[center]" + str(["RED","BLUE"][main.currentTurn[0]] + " TURN")
	else:
		nodePlayerText.text = "[center]" + str(["BLUE","RED"][main.currentTurn[0]] + " TURN NEXT")

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_return_button_pressed() -> void:
	if returnWarning > 0:
		get_tree().current_scene.changeScene("res://Scenes/main_menu.tscn")
	else:
		returnWarning = 2
		nodeButtonReturn.text = "Are you sure?"


func _on_quit_button_pressed() -> void:
	if quitWarning > 0:
		get_tree().quit()
	else:
		quitWarning = 2
		$PausePanel/VBoxContainer/QuitButton.text = "Are you sure?"
