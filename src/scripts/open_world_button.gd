extends Button


func _on_pressed() -> void:
	if Global.WorldLoaded:
		var target_dir := Global.WorldPath.get_base_dir().get_base_dir()
		if OS.get_name() == "Windows":
			if target_dir.begins_with("//"):
				target_dir = "\\\\" + target_dir.substr(2).replace("/", "\\")
			else:
				target_dir = target_dir.replace("/", "\\")
		OS.shell_open(target_dir)
		print("[INFO] Opened world folder at: " + target_dir)
	else:
		AlertManager.show_alert("No world selected. Choose a world first.", Color.YELLOW)
