extends Control

@onready var titlebar: RichTextLabel = $"../../../Topbar/Titlebar/HeaderLabel"


func _on_visibility_changed() -> void:
	titlebar.text = "About"
