extends Control

@onready var titlebar: RichTextLabel = $"../../../Topbar/Titlebar/HeaderLabel"


func _ready() -> void:
	# Initialize checkboxes with current settings
	$HBoxContainer/VBoxContainer/CheckBox1.button_pressed = LoadSettings.get_setting("HIDE_DEFAULT_SERVER_PACKS")
	$HBoxContainer/VBoxContainer/CheckBox2.button_pressed = LoadSettings.get_setting("HIDE_TEXT_MODIFIER_SYMBOLS")
	$HBoxContainer/VBoxContainer/CheckBox3.button_pressed = LoadSettings.get_setting("IMPORT_AS_UNIQUE_FOLDER_NAME")

	# Connect signals so changes update the settings file
	$HBoxContainer/VBoxContainer/CheckBox1.toggled.connect(_on_checkbox_toggled.bind("HIDE_DEFAULT_SERVER_PACKS"))
	$HBoxContainer/VBoxContainer/CheckBox2.toggled.connect(_on_checkbox_toggled.bind("HIDE_TEXT_MODIFIER_SYMBOLS"))
	$HBoxContainer/VBoxContainer/CheckBox3.toggled.connect(_on_checkbox_toggled.bind("IMPORT_AS_UNIQUE_FOLDER_NAME"))


func _on_checkbox_toggled(pressed: bool, key: String) -> void:
	LoadSettings.set_setting(key, pressed)


func _on_visibility_changed() -> void:
	titlebar.text = "Settings"
