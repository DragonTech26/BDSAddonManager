extends Control
class_name DialogBox

enum Result { ACCEPT, CANCEL, CLOSED }

signal finished(result: Result) # Emitted when dialog is closed in any way

@onready var title_label: Label = $PanelPopup/VBoxContainer/TitleBar/TitleBarHBox/TitleLabel
@onready var message_label: RichTextLabel = $PanelPopup/VBoxContainer/ContentMargin/Message
@onready var accept_button: Button = $PanelPopup/VBoxContainer/ButtonMargin/ButtonRow/AcceptButton
@onready var cancel_button: Button = $PanelPopup/VBoxContainer/ButtonMargin/ButtonRow/CancelButton
@onready var close_button: Button = $PanelPopup/VBoxContainer/TitleBar/TitleBarHBox/CloseButton


func _ready() -> void:
	accept_button.pressed.connect(_on_accept_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	close_button.pressed.connect(_on_close_pressed)
	Themes.theme_changed.connect(_on_theme_changed)
	Themes.apply_to(self)
	cancel_button.grab_focus()


func setup(title: String, message: String, accept_text: String = "Accept", cancel_text: String = "Cancel") -> void:
	title_label.text = title
	message_label.text = message
	accept_button.text = accept_text
	cancel_button.text = cancel_text


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_cancel_pressed()


func _on_accept_pressed() -> void:
	finished.emit(Result.ACCEPT)
	queue_free()


func _on_cancel_pressed() -> void:
	finished.emit(Result.CANCEL)
	queue_free()


func _on_close_pressed() -> void:
	finished.emit(Result.CLOSED)
	queue_free()


func _on_close_button_mouse_entered() -> void:
	$PanelPopup/VBoxContainer/TitleBar/TitleBarHBox/CloseButton/Icon.modulate = Themes.get_active_palette().danger


func _on_close_button_mouse_exited() -> void:
	$PanelPopup/VBoxContainer/TitleBar/TitleBarHBox/CloseButton/Icon.modulate = Themes.get_active_palette().icon_color_override


func _on_theme_changed(_theme_name: String) -> void:
	Themes.apply_to(self)
