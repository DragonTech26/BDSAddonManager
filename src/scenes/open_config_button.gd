extends Button

func _on_pressed() -> void:
	var path = ProjectSettings.globalize_path("user://")
	OS.shell_open(path)
