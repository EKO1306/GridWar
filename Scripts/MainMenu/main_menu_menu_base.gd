extends Control

@export var startOpen = false


var open = false

func _ready() -> void:
	if startOpen:
		openTab()
	else:
		$NinePatchRect.position = Vector2(99999,99999)

func openTab():
	if open:
		return
	open = true
	$AnimationPlayer.play("Open")
	onOpenTab()
	for i in get_parent().get_children():
		if i == self:
			continue
		i.closeTab()
func closeTab():
	if not open:
		return
	open = false
	$AnimationPlayer.play("Closed")

func onOpenTab():
	pass
