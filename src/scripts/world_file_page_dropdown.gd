extends VBoxContainer

var open: bool = false

@onready var content: VBoxContainer = $Content
@onready var arrow: Button = $Header/ArrowButton
@onready var arrow_icon: TextureRect = $Header/ArrowButton/Icon


func _ready():
	arrow.connect("pressed", _on_arrow_pressed)


func _on_arrow_pressed():
	open = !open
	content.visible = open
	_update_arrow_icon()


func _update_arrow_icon():
	if open:
		arrow_icon.flip_v = true
	else:
		arrow_icon.flip_v = false
