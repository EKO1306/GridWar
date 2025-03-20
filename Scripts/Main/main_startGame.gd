extends Node2D

@export_category("Grid Settings")
@onready var mapName = get_parent().scenePassover.mapName
@onready var mapID = get_parent().scenePassover.mapID
@onready var gridWidth = get_parent().scenePassover.mapWidth
@onready var gridHeight = get_parent().scenePassover.mapHeight
@onready var unitControl = $Units
@onready var tileControl = $Tiles

const traitTooltipList = {
	
	#Defensive
	"defence": {"tooltip": "[color=Deepskyblue]Defence[/color] [color=Springgreen]{0}[/color]\nReduces incoming [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] by [color=Springgreen]{0}[/color].", "traitText": "{0}"}
	,"shield": {"tooltip": "[color=Deepskyblue]Shield[/color] [color=Springgreen]{0}[/color]\nGain [color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/Status/block.png[/img][color=Hotpink]Block[/color] at the start of each turn for 1 turn. [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] taken is dealt to block first.", "traitText": "{0}"}
	,"shieldwall": {"tooltip": "[color=Deepskyblue]Shieldwall[/color]\nGain [img width=24]res://Images/Icons/Status/block.png[/img][color=Hotpink]Block[/color] equal to adjacent allies' [img width=24]res://Images/Icons/Traits/block.png[/img][color=Deepskyblue]Shield[/color] trait value each turn for 1 turn."}
	
	#Movement
	,"charge": {"tooltip": "[color=Deepskyblue]Charge[/color] [color=Springgreen]{0}[/color]\n+[color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/General/Movement.png[/img][color=Skyblue]Movement[/color] until this unit takes an action.", "traitText": "{0}"}
	,"mounted": {"tooltip": "[color=Deepskyblue]Mounted[/color]\nCan't hide. Moving through difficult terrain costs +0.5 [img width=24]res://Images/Icons/General/Movement.png[/img][color=Skyblue]Movement[/color]."}
	,"vigilance": {"tooltip": "[color=Deepskyblue]Vigilance[/color]\nCan move after spending every [img width=24]res://Images/Icons/General/Action.png[/img][color=Indianred]Action Point[/color]."}
	
	#Vision and Hiding
	,"eagleEye": {"tooltip": "[color=Deepskyblue]Eagle Eye[/color] [color=Springgreen]{0}[/color]\nCan see hidden units from +[color=Springgreen]{0}[/color] tile(s) away.", "traitText": "{0}"}
	
	#Misc.
	,"mechanical": {"tooltip": "[color=Deepskyblue]Mechanical[/color]\nCannot be healed, but can be repaired."}
	
	#FACTIONS
	,"factionKingdom": {"tooltip": "[color=Deepskyblue]Bilha Kingdom[/color]\n[i][color=Slategray]For The King![/color][/i]"}
	,"factionViking": {"tooltip": "[color=Deepskyblue]Ulingrad[/color]\n[i][color=Slategray]Once broken, we return for blood and gold![/color][/i]"}
}


const actionTraitTooltipList = {
	#Damage
	"damage": {"tooltip": "[color=Darkorange]Damage[/color] [color=Springgreen]{0}[/color]\nDeals [color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] to the target.", "traitText": "{0}"}
	,"melee": {"tooltip": "[color=Darkorange]Melee Attack[/color]\nThis action is a melee attack."}
	,"ranged": {"tooltip": "[color=Darkorange]Ranged Attack[/color]\nThis action is a ranged attack."}
	
	#Defensive
	,"heal": {"tooltip": "[color=Darkorange]Heal[/color] [color=Springgreen]{0}[/color]\nRestores [color=Springgreen]{0}[/color] health to the target.", "traitText": "{0}"}
	
	#Status
	,"poison": {"tooltip": "[color=Darkorange]Poison[/color] [color=Springgreen]{0}[/color]\nApplies [color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/Status/poisoned.png[/img][color=Hotpink]Poisoned[/color] to the target for 6 turns. Poisoned units lose {0} health each turn.", "traitText": "{0}"}
	,"burn": {"tooltip": "[color=Darkorange]Burn[/color] [color=Springgreen]{0}[/color]\nApplies [color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/Status/burning.png[/img][color=Hotpink]Burning[/color] to the target for 4 turns. Burning deals {0} [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] each turn and the unit cannot hide.", "traitText": "{0}"}
	,"expose": {"tooltip": "[color=Darkorange]Expose[/color] [color=Springgreen]{0}[/color]\nApplies [img width=24]res://Images/Icons/Status/exposed.png[/img][color=Hotpink]Exposed[/color] to the target for {0} turn(s). Exposed units cannot hide.", "traitText": "{0}"}
	
	#Usage
	,"use": {"tooltip": "[color=Springgreen]{1}[/color] [color=Darkorange]Use(s)[/color]\nThis action may only be used [color=Springgreen]{1}[/color] time(s) total.", "traitText": "{0}/{1}"}
	,"usePerTurn": {"tooltip": "[color=Springgreen]{1}[/color] [color=Darkorange]Use(s) Per Turn[/color]\nThis action may only be used [color=Springgreen]{1}[/color] time(s) per turn.", "traitText": "{0}/{1}"}
	,"ammo": {"tooltip": "[color=Springgreen]{1}[/color] [color=Darkorange]Ammo[/color]\nUsing this action requires 1 ammo. Other actions can restore ammo.", "traitText": "{0}/{1}"}
	,"reload": {"tooltip": "[color=Darkorange]Reload[/color] [color=Springgreen]{0}[/color]\nRestores [color=Springgreen]{0}[/color] ammo to all of this unit's actions.", "traitText": "{0}"}
	,"rampage": {"tooltip": "[color=Darkorange]Rampage[/color] [color=Springgreen]{0}[/color]\nIf this action kills the target, this unit gains [color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/General/Action.png[/img][color=Indianred]Action Point(s)[/color].", "traitText": "{0}"}
	
	#Misc.
	,"selfTarget": {"tooltip": "[color=Darkorange]Target Self[/color]\nThis action has no target."}
	
	#Specific
	,"ursuanaYaalCommand": {"tooltip": "[color=Darkorange]Ursuana Yaal's Command[/color]\nGives self and ally [img width=24]res://Images/Icons/Traits/mounted.png[/img][color=Deepskyblue]Mounted[/color] units within 2 tiles +1 [img width=24]res://Images/Icons/General/Movement.png[/img][color=Skyblue]Movement[/color] and +50% [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] for 2 turns. Does not stack."}
	}

const statusTooltipList = {
	"charge": {"tooltip": "[color=Hotpink]Charge[/color] [color=Springgreen]{0}[/color]\n+[color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/General/Movement.png[/img][color=Skyblue]Movement[/color] until this unit takes an action.", "traitText": "{0}"}
	,"block": {"tooltip": "[color=Hotpink]Block[/color] [color=Springgreen]{0}[/color]\n[img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] taken is dealt to block first.", "traitText": "{0}"}
	,"burning": {"tooltip": "[color=Hotpink]Burning[/color] [color=Springgreen]{0}[/color]\nDeals [color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] at the start of each turn and can't hide.", "traitText": "{0}"}
	,"poisoned": {"tooltip": "[color=Hotpink]Poisoned[/color] [color=Springgreen]{0}[/color]\nLose [color=Springgreen]{0}[/color] health each turn.", "traitText": "{0}"}
	,"exposed": {"tooltip": "[color=Hotpink]Exposed[/color]\nCannot hide."}
	
	#Specific
	,"ursuanaYaalCommand": {"tooltip": "[color=Hotpink]Ursuana Yaal's Command[/color]\n+1 [img width=24]res://Images/Icons/General/Movement.png[/img][color=Skyblue]Movement[/color] and +50% [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color]."}
}

const unitList = [
	["kingdomPeasant","kingdomSoldier","kingdomShielder","kingdomArcher","kingdomScout","kingdomAssassin","kingdomHealer","kingdomKnight","kingdomCannon","kingdomKingBilly"]
	,["vikingRaider","vikingTorchbearer","vikingBeserker","vikingUrsuanaRider","vikingShieldmaiden","vikingHerbalist","vikingUrsuanaYaal"]
]

# Type 0: Empty (0)
# Type 1: Wall (2)
# Type 2: Bush (4)
# Type 3: Trees (5)
# Type 4: Bridge (1)

@onready var tileGrid = get_parent().scenePassover.mapGrid
var lightGrid = []

func createGrid():
	var tileNo = 0
	for y in gridHeight:
		for x in gridWidth:
			lightGrid.append(false)
			var tile = preload("res://Nodes/tile.tscn").instantiate()
			tile.tileNo = tileNo
			tile.tileX = x
			tile.tileY = y
			tileControl.add_child(tile)
			tileNo += 1
