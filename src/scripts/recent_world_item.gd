extends HBoxContainer

signal edit_pressed(index)
signal delete_pressed(index)

var index: int = -1


func set_enabled(enabled: bool):
	$EditButton.disabled = not enabled


func _on_edit_button_pressed():
	edit_pressed.emit(index)


func _on_remove_button_pressed():
	delete_pressed.emit(index)
