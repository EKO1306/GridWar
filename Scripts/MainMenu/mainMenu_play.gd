extends "main_menu_menu_base.gd"

func _on_back_button_pressed() -> void:
	get_parent().get_node("Main").openTab()
