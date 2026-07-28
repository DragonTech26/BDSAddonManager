extends Node

var confirm_dialog: ConfirmationDialog
var is_editor: bool = false


func _ready() -> void:
	if OS.is_debug_build():
		is_editor = true
		print("[DEBUG] Is debug build: " + str(is_editor))
		print("[DEBUG] Program version: " + ProjectSettings.get_setting("application/config/version"))


# This currently has no effect in the editor, must use release build.
func _notification(what) -> void:
	if what != NOTIFICATION_WM_CLOSE_REQUEST || is_editor:
		return

	if Global.HasUnsavedChanges:
		get_tree().set_auto_accept_quit(false)
		_show_quit_dialog()
		confirm_dialog.get_cancel_button().grab_focus()
	else:
		get_tree().set_auto_accept_quit(true)


func _show_quit_dialog():
	if confirm_dialog == null:
		confirm_dialog = ConfirmationDialog.new()
		confirm_dialog.title = "Close Without Saving?"
		confirm_dialog.dialog_text = "World '" + Global.WorldName + "' has unsaved changes, close without saving?"
		confirm_dialog.always_on_top = true
		confirm_dialog.exclusive = true
		confirm_dialog.confirmed.connect(_on_confirm_quit)
		add_child(confirm_dialog)

		var exit_button := confirm_dialog.get_ok_button()
		exit_button.modulate = Color.CRIMSON
		exit_button.text = "Don't Save"

	confirm_dialog.popup_centered()


func _on_confirm_quit():
	print("[INFO] World closed without saving changes")
	get_tree().quit()
