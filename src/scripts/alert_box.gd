extends Control

@onready var panel: Panel = $MessagePanel
@onready var label: RichTextLabel = $MessagePanel/RichTextLabel
@onready var progress_bar: Panel = $MessagePanel/ProgressBar
@onready var anim: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	AlertManager.register_alert_box(self)


func show_alert(message: String, color: Color):
	label.text = message
	panel.modulate = color
	var sb := StyleBoxFlat.new()
	sb.bg_color = Themes.get_active_palette().accent
	progress_bar.add_theme_stylebox_override("panel", sb)
	anim.stop()
	anim.play("alert_animation")


# Success: Themes.get_active_palette().success
# Warning: Themes.get_active_palette().warning
# Error: Themes.get_active_palette().danger
#AlertManager.show_alert("Hello", Themes.get_active_palette().success)
