extends Control

@export var startOpen = false

@export var openWithTab : Array[Node]
@export var openOnEsc : Node

var open = false

func _ready() -> void:
	if startOpen:
		openTab()
	else:
		$NinePatchRect.position = Vector2(99999,99999)
	postReady()

func _process(delta: float) -> void:
	if open:
		if Input.is_action_just_pressed("pause_game"):
			if openOnEsc != null:
				openOnEsc.openTab()
		
		postProcess()

func postProcess():
	pass

func postReady():
	pass

func openTab():
	if open:
		return
	onOpenTab()
	for i in get_parent().get_children():
		if i == self:
			continue
		if i is RichTextLabel:
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
	onCloseTab()

func onCloseTab():
	pass

func onOpenTab():
	if open:
		return
	open = true
	$AnimationPlayer.play("Open")
