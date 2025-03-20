extends TextureButton

@onready var main = get_tree().current_scene.get_child(0)

@export var brushTool = "brush"
@export var brushType = 0
@export var brushImage = "Grass"

func _pressed() -> void:
	main.brush = {"tool": brushTool, "type": brushType, "image": brushImage}
