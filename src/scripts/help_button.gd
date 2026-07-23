extends Button

@onready var about_screen: ColorRect = $"../../../../../../HelpScreen"
@onready var titlebar: RichTextLabel = $"../../../../../../../../../../Topbar/Titlebar/HeaderLabel"


func _on_pressed() -> void:
	about_screen.visible = true
	titlebar.text = "Help"
