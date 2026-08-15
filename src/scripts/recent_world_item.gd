extends HBoxContainer

signal edit_pressed(index)
signal delete_pressed(index)

var index: int = -1


func _ready() -> void:
	$RemoveButton/Icon.add_to_group("danger")
	add_to_group("recent_world_item_panel")
	Themes.theme_changed.connect(_on_theme_changed)
	call_deferred("_apply_theme")


func set_enabled(enabled: bool):
	$EditButton.disabled = not enabled
	$EditButton/Icon.modulate = Themes.get_active_palette().icon_color_override if enabled else Themes.get_active_palette().secondary_text


func _on_edit_button_pressed():
	edit_pressed.emit(index)


func _on_edit_button_mouse_entered() -> void:
	if not $EditButton.disabled:
		$EditButton/Icon.modulate = Themes.get_active_palette().icon_hover_color


func _on_edit_button_mouse_exited() -> void:
	if not $EditButton.disabled:
		$EditButton/Icon.modulate = Themes.get_active_palette().icon_color_override


func _on_remove_button_pressed():
	delete_pressed.emit(index)


func _on_remove_button_mouse_entered() -> void:
	$RemoveButton/Icon.modulate = Themes.get_active_palette().danger


func _on_remove_button_mouse_exited() -> void:
	$RemoveButton/Icon.modulate = Themes.get_active_palette().icon_color_override


func _on_theme_changed(_theme_name: String) -> void:
	_apply_theme()


func apply_theme() -> void:
	call_deferred("_apply_theme")


func _apply_theme() -> void:
	Themes.apply_to(self)
