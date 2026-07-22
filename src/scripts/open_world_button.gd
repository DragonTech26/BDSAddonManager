extends Button


func _on_pressed() -> void:
	if Global.WorldLoaded:
		OS.shell_open(Global.WorldPath.get_base_dir().get_base_dir())
		print("[INFO] Opened world folder at: " + Global.WorldPath.get_base_dir().get_base_dir())
	else:
		AlertManager.show_alert("No world selected. Choose a world first.", Color.YELLOW)
