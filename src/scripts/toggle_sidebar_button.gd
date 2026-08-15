extends Control

var is_sidebar_open: bool = false

@onready var anim_player = $"../../../AnimationPlayer"
@onready var background: ColorRect = $Background

var _hovered: bool = false


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	Themes.theme_changed.connect(_on_theme_changed)
	set_meta("hovered", false)
	_apply_theme()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_sidebar_open:
				anim_player.play_backwards("sidebar_animation")
			else:
				anim_player.play("sidebar_animation")

			is_sidebar_open = !is_sidebar_open


func _on_mouse_entered() -> void:
	_hovered = true
	set_meta("hovered", true)
	_apply_theme()


func _on_mouse_exited() -> void:
	_hovered = false
	set_meta("hovered", false)
	_apply_theme()


func _on_theme_changed(_theme_name: String) -> void:
	_apply_theme()


func _apply_theme() -> void:
	var palette = Themes.get_active_palette()
	if palette == null:
		return
	background.color = palette.sidebar_hover_bg if _hovered else palette.sidebar_bg
