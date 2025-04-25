extends Control

@export var startOpen = false

@export var openWithTab : Array[Node]

var open = false

func _ready() -> void:
	if startOpen:
		openTab()
	else:
		$NinePatchRect.position = Vector2(99999,99999)

func openTab():
	if open:
		return
	onOpenTab()
	for i in get_parent().get_children():
		if i == self:
			continue
		for a in openWithTab:
			if i == a:
				continue
		i.closeTab()
		for a in openWithTab:
			a.onOpenTab()

func closeTab():
	if not open:
		return
	open = false
	$AnimationPlayer.play("Closed")

func onOpenTab():
	if open:
		return
	open = true
	$AnimationPlayer.play("Open")
