extends Area2D

@export var gridX = 0
@export var gridY = 0
@export var unitTeam = 0

var rng = RandomNumberGenerator.new()

@onready var main = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	updatePos()
	$Sprites.material = ShaderMaterial.new()
	$Sprites.material.shader = preload("res://Shaders/unitOutline.gdshader")
	$AnimationPlayer.play("Idle")
	$AnimationPlayer.speed_scale = rng.randf_range(0.9,1.1)
	if unitTeam == 0:
		$Sprites.material.set_shader_parameter("line_color",Color(1,0,0))
		$Sprites.scale = Vector2(1,1)
	elif unitTeam == 1:
		$Sprites.material.set_shader_parameter("line_color",Color(0,0,1))
		$Sprites.scale = Vector2(-1,1)
	
func _process(_delta):
	z_index = gridY * 2 + 1
	if main.selectedUnit == self:
		$Sprites.modulate = Color(100,100,100,1)
		$Sprites.self_modulate = Color(0.01,0.01,0.01,1)
	else:
		$Sprites.modulate = Color(1,1,1,1)
		$Sprites.self_modulate = Color(1,1,1,1)
	updatePos()
	if main.selectedUnit == self:
		if Input.is_action_just_pressed("move_left"):
				moveTo(gridX-1,gridY)
		if Input.is_action_just_pressed("move_right"):
				moveTo(gridX+1,gridY)
		if Input.is_action_just_pressed("move_up"):
				moveTo(gridX,gridY-1)
		if Input.is_action_just_pressed("move_down"):
				moveTo(gridX,gridY+1)

func _input_event(_viewport,event,_shapeidx):
	if event.is_action_pressed("left_click"):
		if main.selectedUnit == self:
			main.selectedUnit = null
		else:
			main.selectedUnit = self

func updatePos():
	global_position.x = (gridX*24)-12
	global_position.y = (gridY*24)-12
	global_position.y -= main.tileGrid[gridX+(gridY*main.gridWidth)][2] * 4
	
func moveTo(x,y):
	var currentTile = main.getTileAtXY(gridX,gridY)
	var targetTile = main.getTileAtXY(x,y)
	if x > gridX:
		$Sprites.scale = Vector2(1,1)
	if x < gridX:
		$Sprites.scale = Vector2(-1,1)
		
	if x > main.gridWidth-1:
		return
	if x < 0:
		return
	if y > main.gridHeight-1:
		return
	if y < 0:
		return
	
	if abs(currentTile[2] - targetTile[2]) >= 2:
		return
	
	if main.getUnitAtXY(x,y) != null:
		return
	gridX = x
	gridY = y
	
