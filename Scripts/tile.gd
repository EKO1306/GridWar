extends Control

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
	tileLit = main.lightGrid[tileNo]
	if main.tileGrid[tileNo].type == 1:
		tileLit = false
	if main.tileGrid[tileNo].image == "Lava":
		tileLit = true
	if tileLit:
		for i in get_children():
			i.modulate = Color(1,1,1)
	else:
		for i in get_children():
			i.modulate = Color(0.6,0.3,0.5)

func updateTileVariables():
	currentTile = main.tileGrid[tileNo]
	tileHeight = currentTile.height

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	updateTileVariables()
	$AnimatedSprite2D.play(currentTile.image)
	global_position.x = tileX*24 - 12
	global_position.y = tileY*24-tileHeight*4 - 12
	z_index = tileY * 2
	scale.y = 1
	if main.getTileAtXY(tileX,tileY).image == "Lava" or main.getTileAtXY(tileX,tileY).type == 5:
		var tileHeightDiff = main.getTileAtXY(tileX,tileY+1)
		if tileHeightDiff == null:
			tileHeightDiff = tileHeight
		else:
			tileHeightDiff = tileHeight - tileHeightDiff.height
		var sinValue = (sin(Time.get_ticks_msec() * 0.002) * 0.075) + 0.075
		scale.y = 1 + ((6 / float(tileHeightDiff + 6)) * sinValue)
		position.y -= 24 * sinValue
	
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
		if currentTile.get("undertile") != null:
			var undertile = createTexture(Vector2(0,12),spriteFrame.get_frame_texture(currentTile.undertile,0))
			undertile.self_modulate = Color((0.6+(tileHeight*0.1)) * 0.2875,(0.6+(tileHeight*0.1)) * 0.2875,(0.6+(tileHeight*0.1)) * 0.2875)
			
	for i in range(heightDifference):
		if i == 0:
			underImage = spriteFrame.get_frame_texture(currentTile.image,i+1)
		else:
			if i == heightDifference - 1:
				underImage = spriteFrame.get_frame_texture(currentTile.image,4)
			else:
				underImage = spriteFrame.get_frame_texture(currentTile.image,((i + 1) % 2) + 2)
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
			$ShadowUp.position.y = (1-((-heightDiffUp)/3.0))*12 + 12
			$ShadowUp.modulate.a = (-heightDiffUp)/8.0 + 0.5
	if heightDiffDown != null:
		heightDiffDown = tileHeight-heightDiffDown.height
		if heightDiffDown < 0:
			$ShadowDown.visible = true
			$ShadowDown.scale.y = (-heightDiffDown)/8.0
			$ShadowDown.position.y = (1-((-heightDiffDown)/8.0))*-12 + 12
			$ShadowDown.modulate.a = (-heightDiffDown)/4.0
	if heightDiffLeft != null:
		heightDiffLeft = tileHeight-heightDiffLeft.height
		if heightDiffLeft < 0:
			$ShadowLeft.visible = true
			$ShadowLeft.scale.y = (-heightDiffLeft)/8.0
			$ShadowLeft.position.x = (1-((-heightDiffLeft)/8.0))*-12 + 12
			$ShadowLeft.modulate.a = (-heightDiffLeft)/4.0
	if heightDiffRight != null:
		heightDiffRight = tileHeight-heightDiffRight.height
		if heightDiffRight < 0:
			$ShadowRight.visible = true
			$ShadowRight.scale.y = (-heightDiffRight)/8.0
			$ShadowRight.position.x = (1-((-heightDiffRight)/8.0))*12 + 12
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
	spriteNode.position = spritePosition + Vector2(12,12)
	spriteNode.texture = texture
	spriteNode.show_behind_parent = showBehind
	spriteNode.modulate = colorOffset
	spriteNode.y_sort_enabled = ySort
	spriteNode.z_index = zLevel
	add_child(spriteNode)
	return spriteNode

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.pressed:
				if main.mapEditor:
					main.brushTile(tileX, tileY)
					return
				if tileLit:
					var unit = main.getUnitAtXY(tileX,tileY)
					if main.armyBuilder:
						if unit == null:
							main.spawnUnit(main.selectedUnit	 + ".tscn",tileX,tileY,main.currentTurn[0])
						else:
							unit.free()
						main.updateScreen()
						return
					else:
						if main.selectedAction != null:
							main.selectedUnit.calcAction(unit,Vector2(tileX, tileY))
							main.updateScreen()
							return
						if unit != null:
							unit.unitClicked()
							return
