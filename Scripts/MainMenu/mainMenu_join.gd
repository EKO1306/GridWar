extends "main_menu_menu_base.gd"

func postReady():
	if get_tree().get_current_scene().scenePassover.has("multiplayerPanels"):
		if not OnlineHandler.multiplayer.is_server():
			openTab()

func postProcess():
	$NinePatchRect/Status.text = "Status: "
	if OnlineHandler.peer == null:
		$NinePatchRect/Status.text += "Not joined."
		$NinePatchRect/JoinButton.disabled = false
	else:
		var connectionStatus = OnlineHandler.peer.get_connection_status()
		if connectionStatus == 2:
			$NinePatchRect/Status.text += "Server Connected!"
			$NinePatchRect/JoinButton.disabled = true
		elif connectionStatus == 1:
			$NinePatchRect/Status.text += "Connecting..."
			$NinePatchRect/JoinButton.disabled = true
		else:
			$NinePatchRect/Status.text += "Client Disconnected."
			$NinePatchRect/JoinButton.disabled = false

func _on_join_button_pressed() -> void:
	OnlineHandler.address = $NinePatchRect/LineEdit.text
	OnlineHandler.joinGame()

func _on_back_button_pressed() -> void:
	get_parent().get_node("Play").openTab()

func onCloseTab():
	OnlineHandler.closeOnline()
