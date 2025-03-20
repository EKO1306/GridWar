extends Node2D

var scenePassover
var changingScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(preload("res://Scenes/main_menu.tscn").instantiate())

func _process(_delta: float) -> void:
	if changingScene != null:
		add_child(load(changingScene).instantiate())
		changingScene = null

func changeScene(scene, passover = null):
	scenePassover = passover
	for i in get_children():
		i.queue_free()
	changingScene = scene
	get_tree().paused = false
