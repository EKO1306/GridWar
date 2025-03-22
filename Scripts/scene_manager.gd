extends Node2D

var scenePassover
var changingScene
var main

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main = preload("res://Scenes/main_menu.tscn").instantiate()
	add_child(main)

func _process(_delta: float) -> void:
	if changingScene != null:
		main = load(changingScene).instantiate()
		add_child(main,true)
		changingScene = null

@rpc("any_peer","call_remote", "reliable")
func changeScene(scene, passover = null):
	scenePassover = passover
	for i in get_children():
		i.queue_free()
	changingScene = scene
	get_tree().paused = false
