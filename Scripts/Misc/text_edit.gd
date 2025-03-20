extends LineEdit

@export var allowedCharacters = ""
@export var disallowedCharacters = ""
@export var specialFlags = []

func _on_text_submitted(_new_text: String) -> void:
	cleanText(text)

func cleanText(new_text):
	var finalText = new_text
	for i in disallowedCharacters:
		finalText = finalText.replace(i, "")
	if len(allowedCharacters) > 0:
		var foundIllegalCharacters = []
		for i in new_text:
			if not allowedCharacters.contains(i):
				foundIllegalCharacters.append(i)
		for i in foundIllegalCharacters:
			finalText = finalText.replace(i, "")
	
	if specialFlags.has("snake"):
		finalText = finalText.to_snake_case()
	
	var column = caret_column
	text = finalText
	caret_column = column



func _on_focus_exited() -> void:
	cleanText(text)
