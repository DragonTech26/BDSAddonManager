extends Control

var is_sidebar_open: bool = false

@onready var anim_player = $"../../../AnimationPlayer"


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_sidebar_open:
				anim_player.play_backwards("sidebar_animation")
			else:
				anim_player.play("sidebar_animation")

			is_sidebar_open = !is_sidebar_open
