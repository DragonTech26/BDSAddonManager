extends Button

signal reset_confirmed

var _confirm_dialog: ConfirmationDialog


func _on_pressed() -> void:
	if Global.WorldLoaded:
		if _confirm_dialog == null:
			_confirm_dialog = ConfirmationDialog.new()
			_confirm_dialog.title = "Unload world?"
			add_child(_confirm_dialog)
			_confirm_dialog.confirmed.connect(_on_confirm)
		_confirm_dialog.dialog_text = "Do you want to unload world: " + Global.WorldName + "?\nAny unsaved changes will be lost."
		_confirm_dialog.popup_centered()
	else:
		AlertManager.show_alert("No world selected. Choose a world first.", Color.YELLOW)


func _on_confirm() -> void:
	reset_confirmed.emit()
