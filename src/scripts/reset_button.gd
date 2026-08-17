extends Button

signal reset_confirmed

const DialogBoxScene = preload("res://src/scenes/dialog_box.tscn")


func _on_pressed() -> void:
	if Global.WorldLoaded:
		var dialog := DialogBoxScene.instantiate()
		get_tree().current_scene.add_child(dialog)
		dialog.setup("Unload world?", "Do you want to unload world: " + Global.WorldName + "?\nAny unsaved changes will be lost!", "OK", "Cancel")
		var result: DialogBox.Result = await dialog.finished
		if result == DialogBox.Result.ACCEPT:
			_on_confirm()
	else:
		AlertManager.show_alert("No world selected. Choose a world first.", Themes.get_active_palette().warning)


func _on_confirm() -> void:
	reset_confirmed.emit()
