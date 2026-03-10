extends "main_menu_menu_base.gd"

func _on_play_button_pressed() -> void:
	get_parent().get_node("Play").openTab()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
