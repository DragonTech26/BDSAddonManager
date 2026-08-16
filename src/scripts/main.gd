extends Control

const DialogBoxScene = preload("res://src/scenes/dialog_box.tscn")

var is_editor: bool = false


func _ready() -> void:
	if OS.is_debug_build():
		is_editor = true
		print("[DEBUG] Is debug build: " + str(is_editor))
		print("[DEBUG] Program version: " + ProjectSettings.get_setting("application/config/version"))

	theme = Themes.get_active_theme()
	Themes.theme_changed.connect(_on_theme_changed)
	Themes.apply_to(self)


# This currently has no effect in the editor, must use release build.
func _notification(what) -> void:
	if what != NOTIFICATION_WM_CLOSE_REQUEST || is_editor:
		return

	if Global.HasUnsavedChanges:
		get_tree().set_auto_accept_quit(false)
		_show_quit_dialog()
	else:
		get_tree().set_auto_accept_quit(true)


func _show_quit_dialog():
	var dialog := DialogBoxScene.instantiate()
	get_tree().current_scene.add_child(dialog)
	dialog.setup("Close without saving?", "World '" + Global.WorldName + "' has unsaved changes! Are you sure you want to exit?", "Don't Save", "Cancel")
	var result: DialogBox.Result = await dialog.finished
	if result == DialogBox.Result.ACCEPT:
		_on_confirm_quit()


func _on_confirm_quit():
	print("[INFO] World closed without saving changes")
	get_tree().quit()


func _on_theme_changed(_theme_name: String) -> void:
	theme = Themes.get_active_theme()
	Themes.apply_to(self)
