extends Control

@export var icon: CompressedTexture2D
@export var label: String = "Placeholder"
@export var active: bool = false
@export var page: NodePath


func _ready():
	$icon.texture = icon
	$RichTextLabel.text = label
	update_elements()


func set_active(value: bool):
	active = value
	update_elements()


func update_elements():
	$active.visible = active
	get_node(page).visible = active


func _on_mouse_entered() -> void:
	$Background.color = "#3B4A5B"


func _on_mouse_exited() -> void:
	$Background.color = "#363D4A"


func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var navitems: Array[Node] = get_tree().get_nodes_in_group("navitem")
			for item in navitems:
				item.set_active(false)
			set_active(true)
