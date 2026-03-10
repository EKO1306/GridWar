extends RichTextLabel

func _ready() -> void:
	text = "Game Version: v" + ProjectSettings.get_setting("application/config/version")
