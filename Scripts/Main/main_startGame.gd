extends "main_save_load_multiplayer.gd"

const traitTooltipList = {
	
	#Defensive
	"defence": {"tooltip": "[color=Deepskyblue]Defence[/color] [color=Springgreen]{0}[/color]\nReduces incoming [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] by [color=Springgreen]{0}[/color].", "traitText": "{0}"}
	,"shield": {"tooltip": "[color=Deepskyblue]Shield[/color] [color=Springgreen]{0}[/color]\nGain [color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/Status/block.png[/img][color=Hotpink]Block[/color] at the start of each turn for 1 turn. [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] taken is dealt to block first.", "traitText": "{0}"}
	,"shieldwall": {"tooltip": "[color=Deepskyblue]Shieldwall[/color]\nGain [img width=24]res://Images/Icons/Status/block.png[/img][color=Hotpink]Block[/color] equal to adjacent allies' [img width=24]res://Images/Icons/Traits/block.png[/img][color=Deepskyblue]Shield[/color] trait value each turn for 1 turn."}
	,"moltenDefence": {"tooltip": "[color=Deepskyblue]Molten Defence[/color] [color=Springgreen]{0}[/color]\nThe first incoming [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] each turn is reduced by [color=Springgreen]{0}[/color].", "traitText": "{0}"}

	
	#Health
	,"fading": {"tooltip": "[color=Deepskyblue]Fading[/color] [color=Springgreen]{0}[/color]\nLoses [color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/General/Health.png[/img][color=Lime]Health[/color] each turn.", "traitText": "{0}"}
	,"lifeless": {"tooltip": "[color=Deepskyblue]Lifeless[/color]\nCannot regain [img width=24]res://Images/Icons/General/Health.png[/img][color=Lime]Health[/color]."}
	,"bloodRain": {"tooltip": "[color=Deepskyblue]Blood Rain[/color] [color=Springgreen]{0}[/color]\nAt the start of each turn, self and allies within 3 tiles [img width=24]res://Images/Icons/ActionTraits/Heal.png[/img][color=Lime]Heal[/color] [color=Springgreen]{0}[/color].\n[i][color=Slategray](Does not affect [img width=24]res://Images/Icons/Traits/mechanical.png[/img][color=Deepskyblue]Mechanical[/color] units.)[/color][/i]", "traitText": "{0}"}

	#[img width=24]res://Images/Icons/General/Health.png[/img][color=Lime]Health[/color]
	
	#Movement
	,"charge": {"tooltip": "[color=Deepskyblue]Charge[/color] [color=Springgreen]{0}[/color]\n+[color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/General/Movement.png[/img][color=Skyblue]Movement[/color] until this unit takes an action.", "traitText": "{0}"}
	,"mounted": {"tooltip": "[color=Deepskyblue]Mounted[/color]\nCan't hide. Moving through difficult terrain costs +0.5 [img width=24]res://Images/Icons/General/Movement.png[/img][color=Skyblue]Movement[/color]."}
	,"vigilance": {"tooltip": "[color=Deepskyblue]Vigilance[/color]\nCan move after spending every [img width=24]res://Images/Icons/General/Action.png[/img][color=Indianred]Action Point[/color]."}
	,"flying": {"tooltip": "[color=Deepskyblue]Flying[/color]\nCan't hide. Ignores all terrain movement penalties, and may move over cliffs of any height."}
	,"immobile": {"tooltip": "[color=Deepskyblue]Immobile[/color]\nCannot move or be moved."}
	
	#Vision and Hiding
	,"eagleEye": {"tooltip": "[color=Deepskyblue]Eagle Eye[/color] [color=Springgreen]{0}[/color]\nCan see hidden units from +[color=Springgreen]{0}[/color] tile(s) away.", "traitText": "{0}"}
	,"exposed": {"tooltip": "[color=Deepskyblue]Exposed[/color]\nCannot hide."}
	,"blind": {"tooltip": "[color=Deepskyblue]Blind[/color] [color=Springgreen]{0}[/color]\nCan only see up to [color=Springgreen]{0}[/color] tile(s) away.", "traitText": "{0}"}
	
	#Fervor
	,"faithful": {"tooltip": "[color=Deepskyblue]Faithful[/color] [color=Springgreen]{0}[/color], [color=Springgreen]{1}[/color]\nApon killing an enemy unit, gains {0} Fervor. When this unit dies, Faithful allies within 2 tiles gain {1} Fervor.", "traitText": "{0}, {1}"}
	
	#Death
	,"wrathIncarnate": {"tooltip": "[color=Deepskyblue]Wrath Incarnate[/color]\nWhen this unit dies, inflicts [img width=24]res://Images/Icons/Status/wrath.png[/img][color=Hotpink]Wrath[/color] on ALL units for 3 turns. Units with [img width=24]res://Images/Icons/Status/wrath.png[/img][color=Hotpink]Wrath[/color] cannot use non-attack actions."}
	
	#Misc.
	,"mechanical": {"tooltip": "[color=Deepskyblue]Mechanical[/color]\nCannot be healed, but can be repaired."}
	,"infernalInvader": {"tooltip": "[color=Deepskyblue]Infernal Invader[/color] [color=Springgreen]{0}[/color]\nLoses [color=Springgreen]{1}[/color] [img width=24]res://Images/Icons/General/Health.png[/img][color=Lime]Health[/color] each turn. Apon killing an enemy unit, permenantly gains [color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] and [color=Springgreen]{2}[/color] [img width=24]res://Images/Icons/General/Health.png[/img][color=Lime]Max Health[/color]. This is doubled if the killed unit's [img width=24]res://Images/Icons/General/Value.png[/img][color=Gold]Value[/color] is above this unit's [img width=24]res://Images/Icons/General/Value.png[/img][color=Gold]Value[/color].", "traitText": "{0}"}
	,"immortalLord": {"tooltip": "[color=Deepskyblue]Immortal Lord[/color]\nAt the start of battle, [img width=24]res://Images/Icons/Status/Summon.png[/img][color=Hotpink]Summons[/color] 2 Infernal Totems. If this unit would die, instead this unit teleports onto an ally Totem's tile and erases it, and has their health set to 50%."}
	,"unholyWarlord": {"tooltip": "[color=Deepskyblue]Unholy Warlord[/color]\nALL other allies gain +100% [img width=24]res://Images/Icons/General/Health.png[/img][color=Lime]Max Health[/color] and [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] from [img width=24]res://Images/Icons/Traits/infernalInvader.png[/img][color=Deepskyblue]Infernal Invader[/color]."}
	,"gildedHoarder": {"tooltip": "[color=Deepskyblue]Gilded Hoarder[/color]\nDeals +20 [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] and gains 40 [img width=24]res://Images/Icons/Status/block.png[/img][color=Hotpink]Block[/color] each turn for each ally Uneeded Oppulence. Apon killing an enemy unit, spawns an Uneeded Oppulence on or adjacent to that unit's tile."}
	
	#FACTIONS
	,"factionKingdom": {"tooltip": "[color=Deepskyblue]Bilha Kingdom[/color]\n[i][color=Slategray]For The King![/color][/i]"}
	,"factionViking": {"tooltip": "[color=Deepskyblue]Ulingrad[/color]\n[i][color=Slategray]Once broken, we return for blood and gold![/color][/i]"}
	,"factionDemon": {"tooltip": "[color=Deepskyblue]Legiones Daemonica[/color]\n[i][color=Slategray]You call us monsters, yet we are the memories you discard. So what does that make you?[/color][/i]"}
	,"factionAngel": {"tooltip": "[color=Deepskyblue]Angels of the Awakened[/color]\n[i][color=Slategray]We stand for the Awakened One. We are Judge, Jury, Executioner, will of the people, and scourge of the heretic.[/color][/i]"}
}


const actionTraitTooltipList = {
	#Damage
	"damage": {"tooltip": "[color=Darkorange]Damage[/color] [color=Springgreen]{0}[/color]\nDeals [color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] to the target.", "traitText": "{0}"}
	,"melee": {"tooltip": "[color=Darkorange]Melee Attack[/color]\nThis action is a melee attack."}
	,"ranged": {"tooltip": "[color=Darkorange]Ranged Attack[/color]\nThis action is a ranged attack."}
	,"recoil": {"tooltip": "[color=Darkorange]Recoil[/color] [color=Springgreen]{0}[/color]\n This unit deals [color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] to itself on use.", "traitText": "{0}"}
	
	#Defensive
	,"heal": {"tooltip": "[color=Darkorange]Heal[/color] [color=Springgreen]{0}[/color]\nRestores [color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/General/Health.png[/img][color=Lime]Health[/color] to the target.\n[i][color=Slategray](Does not affect [img width=24]res://Images/Icons/Traits/mechanical.png[/img][color=Deepskyblue]Mechanical[/color] units.)[/color][/i]", "traitText": "{0}"}
	,"devour": {"tooltip": "[color=Darkorange]Devour[/color]\nDeals +1000 [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] to allies. Killing a unit with this action restores [img width=24]res://Images/Icons/General/Health.png[/img][color=Lime]Health[/color] to this unit equal to half the target's [img width=24]res://Images/Icons/General/Health.png[/img][color=Lime]Max Health[/color]."}

	#Movement
	,"teleport": {"tooltip": "[color=Darkorange]Teleport[/color]\nTeleports to the target tile."}
	
	#Status
	,"poison": {"tooltip": "[color=Darkorange]Poison[/color] [color=Springgreen]{0}[/color]\nApplies [color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/Status/poisoned.png[/img][color=Hotpink]Poisoned[/color] to the target for 5 turns. Poisoned units lose {0} [img width=24]res://Images/Icons/General/Health.png[/img][color=Lime]Health[/color] each turn.", "traitText": "{0}"}
	,"burn": {"tooltip": "[color=Darkorange]Burn[/color] [color=Springgreen]{0}[/color]\nApplies [color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/Status/burning.png[/img][color=Hotpink]Burning[/color] to the target for 3 turns. Burning deals [color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] each turn and the unit cannot hide.", "traitText": "{0}"}
	,"expose": {"tooltip": "[color=Darkorange]Expose[/color] [color=Springgreen]{0}[/color]\nApplies [img width=24]res://Images/Icons/Status/exposed.png[/img][color=Hotpink]Exposed[/color] to the target for {0} turn(s). Exposed units cannot hide.", "traitText": "{0}"}
	
	#Usage
	,"use": {"tooltip": "[color=Springgreen]{1}[/color] [color=Darkorange]Use(s)[/color]\nThis action may only be used [color=Springgreen]{1}[/color] time(s) total.", "traitText": "{0}/{1}"}
	,"usePerTurn": {"tooltip": "[color=Springgreen]{1}[/color] [color=Darkorange]Use(s) Per Turn[/color]\nThis action may only be used [color=Springgreen]{1}[/color] time(s) per turn.", "traitText": "{0}/{1}"}
	,"ammo": {"tooltip": "[color=Springgreen]{1}[/color] [color=Darkorange]Ammo[/color]\nUsing this action requires 1 ammo. Other actions can restore ammo.", "traitText": "{0}/{1}"}
	,"reload": {"tooltip": "[color=Darkorange]Reload[/color] [color=Springgreen]{0}[/color]\nRestores [color=Springgreen]{0}[/color] ammo to all of this unit's actions.", "traitText": "{0}"}
	,"rampage": {"tooltip": "[color=Darkorange]Rampage[/color] [color=Springgreen]{0}[/color]\nIf this action kills an enemy target, this unit gains [color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/General/Action.png[/img][color=Indianred]Action Point(s)[/color].", "traitText": "{0}"}
	
	#Misc.
	,"selfTarget": {"tooltip": "[color=Darkorange]Target Self[/color]\nThis action has no target."}
	,"summon": {"tooltip": "[color=Darkorange]Summon[/color] [color=Springgreen]{1}[/color]\n[img width=24]res://Images/Icons/Status/Summon.png[/img][color=Hotpink]Summons[/color] a(n) [color=Springgreen]{1}[/color] on the target tile.", "traitText": "{1}"}
	,"possess": {"tooltip": "[color=Deepskyblue]Possess[/color] [color=Springgreen]{0}[/color]\nTarget Unit with [img width=24]res://Images/Icons/General/Value.png[/img][color=Gold]Value[/color] [color=Springgreen]{0}[/color] or less switches to this unit's team. If this unit dies, they return to their original team.", "traitText": "{0}"}
	,"mindBreak": {"tooltip": "[color=Deepskyblue]Mind Break[/color]\nIf the target enemy is killed by this action, they instead switch to this unit's team with 100 [img width=24]res://Images/Icons/General/Health.png[/img][color=Lime]Health[/color], 0 [img width=24]res://Images/Icons/General/Movement.png[/img][color=Skyblue]Movement[/color] and 0 [img width=24]res://Images/Icons/General/Action.png[/img][color=Indianred]Action Points[/color]. If this unit dies, they return to their original team."}

	#Specific
	,"ursuanaYaalCommand": {"tooltip": "[color=Darkorange]Ursuana Yaal's Command[/color]\nGives self and ally [img width=24]res://Images/Icons/Traits/mounted.png[/img][color=Deepskyblue]Mounted[/color] units within 2 tiles +1 [img width=24]res://Images/Icons/General/Movement.png[/img][color=Skyblue]Movement[/color] and +50% [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] for 2 turns. Does not stack."}
	}

const statusTooltipList = {
	#Offensive
	"infernalInvader": {"tooltip": "[color=Hotpink]Infernal Invader[/color] [color=Springgreen]{0}[/color]\n +[color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] and 5x that much [img width=24]res://Images/Icons/General/Health.png[/img][color=Lime]Max Health[/color].", "traitText": "{0}"}
	,"gildedHoarder": {"tooltip": "[color=Hotpink]Gilded Hoarder[/color]\n+[color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color].", "traitText": "{0}"}
	#Defensive
	,"moltenDefence": {"tooltip": "[color=Hotpink]Molten Defence[/color] [color=Springgreen]{0}[/color]\nThe next incoming [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] is reduced by [color=Springgreen]{0}[/color].", "traitText": "{0}"}
	,"block": {"tooltip": "[color=Hotpink]Block[/color] [color=Springgreen]{0}[/color]\n[img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] taken is dealt to block first.", "traitText": "{0}"}

	
	#Damage Over Time
	,"charge": {"tooltip": "[color=Hotpink]Charge[/color] [color=Springgreen]{0}[/color]\n+[color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/General/Movement.png[/img][color=Skyblue]Movement[/color] until this unit takes an action.", "traitText": "{0}"}
	,"burning": {"tooltip": "[color=Hotpink]Burning[/color] [color=Springgreen]{0}[/color]\nDeals [color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] at the start of each turn and can't hide.", "traitText": "{0}", "tickdownAfter": true}
	,"poisoned": {"tooltip": "[color=Hotpink]Poisoned[/color] [color=Springgreen]{0}[/color]\nLose [color=Springgreen]{0}[/color] [img width=24]res://Images/Icons/General/Health.png[/img][color=Lime]Health[/color] each turn.", "traitText": "{0}", "tickdownAfter": true}
	,"exposed": {"tooltip": "[color=Hotpink]Exposed[/color]\nCannot hide."}
	
	#Misc
	,"summon": {"tooltip": "[color=Hotpink]Summon[/color]\nThis unit is a summon. It does not count towards your team's [img width=24]res://Images/Icons/General/Value.png[/img][color=Gold]Value[/color] total."}
	,"ursuanaYaalCommand": {"tooltip": "[color=Hotpink]Ursuana Yaal's Command[/color]\n+1 [img width=24]res://Images/Icons/General/Movement.png[/img][color=Skyblue]Movement[/color] and +50% [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color]."}
	,"unholyWarlord": {"tooltip": "[color=Deepskyblue]Unholy Warlord[/color]\n+100% [img width=24]res://Images/Icons/General/Health.png[/img][color=Lime]Max Health[/color] and [img width=24]res://Images/Icons/General/Damage.png[/img][color=Coral]Damage[/color] from [img width=24]res://Images/Icons/Traits/infernalInvader.png[/img][color=Deepskyblue]Infernal Invader[/color]."}
	,"possessed": {"tooltip": "[color=Hotpink]Possessed[/color]\nThis unit has been possessed by an unknown unit. If that unit dies, it returns to its original team. This unit does not count towards your team's [img width=24]res://Images/Icons/General/Value.png[/img][color=Gold]Value[/color] total."}
	,"wrath": {"tooltip": "[color=Hotpink]Wrath[/color]\nCannot use non-attack actions."}

}

const unitList = [
	["kingdomPeasant","kingdomSoldier","kingdomShielder","kingdomArcher","kingdomScout","kingdomAssassin","kingdomHealer","kingdomKnight","kingdomCannon","kingdomKingBilly"]
	,["vikingRaider","vikingShieldmaiden","vikingTorchbearer","vikingBeserker","vikingUrsuanaRider","vikingHerbalist","vikingUrsuanaYaal"]
	,["demonImp","demonDemon","demonSuccubus","demonBloodPriest","demonShadowDemon","demonGuard","demonWingedGuard","demonInfernalRift","demonRiftcarver","demonArchdaemonica"]
	,["angelCrusader"]
]

# Type 0: Empty (0)
# Type 1: Wall (2)
# Type 2: Bush (4)
# Type 3: Trees (5)
# Type 4: Bridge (1)
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
