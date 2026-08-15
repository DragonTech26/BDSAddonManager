extends VBoxContainer

var open: bool = false

@onready var content: VBoxContainer = $Content
@onready var arrow: Button = $Header/ArrowButton
@onready var arrow_icon: TextureRect = $Header/ArrowButton/Icon


func _ready():
	arrow.connect("pressed", _on_arrow_pressed)
	arrow.connect("mouse_entered", _on_arrow_mouse_entered)
	arrow.connect("mouse_exited", _on_arrow_mouse_exited)


func _on_arrow_pressed():
	open = !open
	content.visible = open
	_update_arrow_icon()


func _update_arrow_icon():
	if open:
		arrow_icon.flip_v = true
	else:
		arrow_icon.flip_v = false


func _on_arrow_mouse_entered() -> void:
	if not arrow.disabled:
		arrow_icon.modulate = Themes.get_active_palette().icon_hover_color


func _on_arrow_mouse_exited() -> void:
	if not arrow.disabled:
		arrow_icon.modulate = Themes.get_active_palette().icon_color_override


func _on_arrow_button_pressed() -> void:
	open = !open
	content.visible = open
	_update_arrow_icon()
