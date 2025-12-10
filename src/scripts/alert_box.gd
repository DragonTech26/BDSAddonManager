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
	sb.bg_color = Color.WHITE
	progress_bar.add_theme_stylebox_override("panel", sb)
	anim.stop()
	anim.play("alert_animation")


# Success: Color.GREEN
# Warning: Color.YELLOW
# Error: Color.CRIMSON
#AlertManager.show_alert("Hello", Color.GREEN)
