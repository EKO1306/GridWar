extends Button

@export var buttonName = "Start"

func _pressed():
	get_parent().button_pressed(buttonName)
