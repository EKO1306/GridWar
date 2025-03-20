extends Camera2D

@export var cameraSpeed = 12

@onready var main = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.get_axis("ui_left", "ui_right") != 0:
		global_position.x += Input.get_axis("ui_left", "ui_right")*cameraSpeed/zoom.x
	if Input.get_axis("ui_up", "ui_down") != 0:
		global_position.y += Input.get_axis("ui_up", "ui_down")*cameraSpeed/zoom.x
	if Input.is_action_just_released("MouseWheelUp"):
		zoom.x = min(zoom.x + 0.5, 10)
		zoom.y = zoom.x
	if Input.is_action_just_released("MouseWheelDown"):
		zoom.x = max(zoom.x - 0.5, 1)
		zoom.y = zoom.x
	
	global_position.x = clamp(global_position.x,-36,(main.gridWidth * 24) + 12)
	global_position.y = clamp(global_position.y,-36,(main.gridHeight * 24) + 12)
