extends "main_startGame.gd"


func getTileAtXY(gridX,gridY):
	if gridX < 0:
		return
	if gridX > gridWidth-1:
		return
	if gridY < 0:
		return
	if gridY > gridHeight-1:
		return
	return tileGrid[gridY*gridWidth+gridX]
	
func getUnitAtXY(x,y):
	for i in unitControl.get_children():
		if i.is_in_group("Unit"):
			if i.gridX == x:
				if i.gridY == y:
					if i.isAlive:
						return i
	return null
