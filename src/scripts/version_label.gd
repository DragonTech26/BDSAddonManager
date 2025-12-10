extends Label

func _ready() -> void:
	self.text = "\nv" + ProjectSettings.get_setting("application/config/version") + "\n"
