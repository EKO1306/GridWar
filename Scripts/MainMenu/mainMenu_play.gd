extends "main_menu_menu_base.gd"

func _on_local_button_pressed() -> void:
	get_parent().get_node("Local").openTab()

func _on_host_button_pressed() -> void:
	get_parent().get_node("Host").openTab()

func _on_join_button_pressed() -> void:
	get_parent().get_node("Join").openTab()

func _on_back_button_pressed() -> void:
	get_parent().get_node("Main").openTab()
