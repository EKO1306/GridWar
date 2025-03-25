extends TextureButton

@onready var main = get_tree().current_scene.get_child(0)

@export var brushTool = "brush"
@export var brushType = 0
@export var brushImage = "Grass"

func _pressed() -> void:
	if main.brush.undertile == null:
		main.brush.undertile = brushImage
	else:
		main.brush.merge({"tool": brushTool, "type": brushType, "image": brushImage}, true)
