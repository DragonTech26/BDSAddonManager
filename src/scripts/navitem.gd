extends Control

@export var icon: CompressedTexture2D
@export var label: String = "Placeholder"
@export var active: bool = false
@export var page: NodePath

@onready var background: ColorRect = $Background
@onready var active_bar: ColorRect = $active

var _hovered: bool = false


func _ready():
	$Icon.texture = icon
	$RichTextLabel.text = label
	Themes.theme_changed.connect(_on_theme_changed)
	set_meta("hovered", false)
	_apply_theme()
	update_elements()


func set_active(value: bool):
	active = value
	update_elements()


func update_elements():
	active_bar.visible = active
	get_node(page).visible = active


func _on_mouse_entered() -> void:
	_hovered = true
	set_meta("hovered", true)
	_apply_theme()


func _on_mouse_exited() -> void:
	_hovered = false
	set_meta("hovered", false)
	_apply_theme()


func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var navitems: Array[Node] = get_tree().get_nodes_in_group("navitem")
			for item in navitems:
				item.set_active(false)
			set_active(true)
			print("[NAVIGATION] Selected page: " + str(page))


func _on_theme_changed(_theme_name: String) -> void:
	_apply_theme()


func _apply_theme() -> void:
	var palette = Themes.get_active_palette()
	if palette == null:
		return
	background.color = palette.sidebar_hover_bg if _hovered else palette.sidebar_bg
	active_bar.color = palette.sidebar_indicator
