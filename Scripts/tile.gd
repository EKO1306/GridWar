extends Area2D

var tileNo
var currentTile
var tileX
var tileY
var tileLit = false

var tileHeight

var rng = RandomNumberGenerator.new()

@onready var main = get_parent().get_parent()
@onready var animatedSprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.

func updateScreen():
	if main.lightGrid[tileNo]:
		tileLit = true
		for i in get_children():
			i.modulate = Color(1,1,1)
	else:
		tileLit = false
		for i in get_children():
			i.modulate = Color(0.6,0.3,0.5)

func updateTileVariables():
	currentTile = main.tileGrid[tileNo]
	tileHeight = currentTile.height

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if main.armyBuilder:
		monitoring = true
	else:
		monitoring = false
	updateTileVariables()
	$AnimatedSprite2D.play(currentTile.image)
	global_position.x = tileX*24
	global_position.y = tileY*24-tileHeight*4
	z_index = tileY * 2
	
func _ready():
	updateTileVariables()
	animatedSprite.self_modulate = Color(0.8+(tileHeight*0.1),0.8+(tileHeight*0.1),0.8+(tileHeight*0.1))
	var spriteFrame = animatedSprite.get_sprite_frames()
	var underImage
	var heightDifference = main.getTileAtXY(tileX,tileY+1)
	drawShadows()
	if heightDifference != null:
		heightDifference = tileHeight-heightDifference.height
		if heightDifference < 0:
			heightDifference = 0
	else:
		heightDifference = tileHeight + 2
	if currentTile.type == 4:
		createTexture(Vector2(0,12),spriteFrame.get_frame_texture("Grass",0),Color(1/5.25,1/7.25,1/10.0)).self_modulate = Color(0.6+(tileHeight*0.1),0.6+(tileHeight*0.1),0.6+(tileHeight*0.1))
		pass
	for i in range(heightDifference):
		if i <= 3:
			underImage = spriteFrame.get_frame_texture(currentTile.image,i+1)
		else:
			underImage = spriteFrame.get_frame_texture(currentTile.image,4)
		createTexture(Vector2(0,((i+1)*4)+10),underImage)
	drawDecor(spriteFrame)
	updateScreen()

func drawShadows():
	var heightDiffUp = main.getTileAtXY(tileX,tileY+1)
	var heightDiffDown = main.getTileAtXY(tileX,tileY-1)
	var heightDiffLeft = main.getTileAtXY(tileX-1,tileY)
	var heightDiffRight = main.getTileAtXY(tileX+1,tileY)
	if heightDiffUp != null:
		heightDiffUp = tileHeight-heightDiffUp.height
		if heightDiffUp < 0:
			$ShadowUp.visible = true
			$ShadowUp.scale.y = min((-heightDiffUp)/3.0,1)
			$ShadowUp.position.y = (1-((-heightDiffUp)/3.0))*12
			$ShadowUp.modulate.a = (-heightDiffUp)/8.0 + 0.5
	if heightDiffDown != null:
		heightDiffDown = tileHeight-heightDiffDown.height
		if heightDiffDown < 0:
			$ShadowDown.visible = true
			$ShadowDown.scale.y = (-heightDiffDown)/8.0
			$ShadowDown.position.y = (1-((-heightDiffDown)/8.0))*-12
			$ShadowDown.modulate.a = (-heightDiffDown)/4.0
	if heightDiffLeft != null:
		heightDiffLeft = tileHeight-heightDiffLeft.height
		if heightDiffLeft < 0:
			$ShadowLeft.visible = true
			$ShadowLeft.scale.y = (-heightDiffLeft)/8.0
			$ShadowLeft.position.x = (1-((-heightDiffLeft)/8.0))*-12
			$ShadowLeft.modulate.a = (-heightDiffLeft)/4.0
	if heightDiffRight != null:
		heightDiffRight = tileHeight-heightDiffRight.height
		if heightDiffRight < 0:
			$ShadowRight.visible = true
			$ShadowRight.scale.y = (-heightDiffRight)/8.0
			$ShadowRight.position.x = (1-((-heightDiffRight)/8.0))*12
			$ShadowRight.modulate.a = (-heightDiffRight)/4.0

func drawDecor(spriteFrame):
	if spriteFrame.get_frame_count(currentTile.image) > 5:
		for y in range(20):
			for x in range(20):
				rng.seed = ((tileY * main.gridHeight + tileX) * 400) + (y*20+x)
				if rng.randi_range(1,5) == 1:
					var zSort = 0
					if y > 15:
						zSort = 1
					createTexture(Vector2(x-9.5,y-9.5),spriteFrame.get_frame_texture(currentTile.image,rng.randi_range(1,spriteFrame.get_frame_count(currentTile.image)-5)+4),Color(1,1,1),false,true,zSort).self_modulate = Color(0.8+(tileHeight*0.1),0.8+(tileHeight*0.1),0.8+(tileHeight*0.1))
			
func createTexture(spritePosition,texture, colorOffset = Color(1,1,1),showBehind = true, ySort = false, zLevel = 0):
	var spriteNode = Sprite2D.new()
	spriteNode.position = spritePosition
	spriteNode.texture = texture
	spriteNode.show_behind_parent = showBehind
	spriteNode.modulate = colorOffset
	spriteNode.y_sort_enabled = ySort
	spriteNode.z_index = zLevel
	add_child(spriteNode)
	return spriteNode

func _input_event(_viewport: Viewport, _event: InputEvent, _shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click"):
		if main.armyBuilder and tileLit:
			if main.getUnitAtXY(tileX,tileY) == null:
				main.spawnUnit(main.selectedUnit	 + ".tscn",tileX,tileY,main.currentTurn[0])
			else:
				main.getUnitAtXY(tileX,tileY).free()
			main.updateScreen()
		elif main.mapEditor:
			main.uiCanvasLayer.updateTile(tileX, tileY)
