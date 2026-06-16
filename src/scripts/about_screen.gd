extends ColorRect

@onready var titlebar: RichTextLabel = $"../../../../../Topbar/Titlebar/HeaderLabel"


func _on_texture_button_pressed() -> void:
	self.visible = false
	titlebar.text = "Settings"
