extends Control

@onready var titlebar: RichTextLabel = $"../../../Topbar/Titlebar/HeaderLabel"
@onready var about_screen: ColorRect = $"../SettingsPage/MarginContainer/AboutScreen"
@onready var check_hide_default_packs: CheckButton = $"../SettingsPage/MarginContainer/VBoxContainer/PageContent/LeftSide/ProgramSettingsPanel/VBoxContainer/HideDefaultPacks/CheckButton"
@onready var check_hide_modifier_symbols: CheckButton = $"../SettingsPage/MarginContainer/VBoxContainer/PageContent/LeftSide/ProgramSettingsPanel/VBoxContainer/HideTextModifiers/CheckButton"
@onready var check_unique_folder_name: CheckButton = $"../SettingsPage/MarginContainer/VBoxContainer/PageContent/LeftSide/FileManagementPanel/VBoxContainer/AvoidConflicts/CheckButton"
@onready var check_system_trash: CheckButton = $"../SettingsPage/MarginContainer/VBoxContainer/PageContent/LeftSide/FileManagementPanel/VBoxContainer/UseSystemTrash/CheckButton"
@onready var recent_world_num: SpinBox = $"../SettingsPage/MarginContainer/VBoxContainer/PageContent/LeftSide/ProgramSettingsPanel/VBoxContainer/RecentWorlds/SpinBox"

@onready var no_world_loaded_label: RichTextLabel = $MarginContainer/VBoxContainer/PageContent/RightSide/VBoxContainer/ServerConnectionInfoPanel/NoWorldLoadedLabel
@onready var world_name_label: RichTextLabel = $MarginContainer/VBoxContainer/PageContent/RightSide/VBoxContainer/ServerConnectionInfoPanel/VBoxContainer/WorldNameLabel
@onready var gamemode_label: RichTextLabel = $MarginContainer/VBoxContainer/PageContent/RightSide/VBoxContainer/ServerConnectionInfoPanel/VBoxContainer/GamemodeLabel
@onready var game_version_label: RichTextLabel = $MarginContainer/VBoxContainer/PageContent/RightSide/VBoxContainer/ServerConnectionInfoPanel/VBoxContainer/GameVersionLabel
@onready var ip_label: RichTextLabel = $MarginContainer/VBoxContainer/PageContent/RightSide/VBoxContainer/ServerConnectionInfoPanel/VBoxContainer/IPLabel


func _ready() -> void:
	check_hide_default_packs.button_pressed = LoadSettings.get_setting("HIDE_DEFAULT_SERVER_PACKS")
	check_hide_modifier_symbols.button_pressed = LoadSettings.get_setting("HIDE_TEXT_MODIFIER_SYMBOLS")
	check_unique_folder_name.button_pressed = LoadSettings.get_setting("IMPORT_AS_UNIQUE_FOLDER_NAME")
	check_system_trash.button_pressed = LoadSettings.get_setting("USE_SYSTEM_TRASH_ON_DELETE")
	recent_world_num.value = LoadSettings.get_setting("RECENT_WORLD_LIST_SIZE")

	check_hide_default_packs.toggled.connect(_on_checkbox_toggled.bind("HIDE_DEFAULT_SERVER_PACKS"))
	check_hide_modifier_symbols.toggled.connect(_on_checkbox_toggled.bind("HIDE_TEXT_MODIFIER_SYMBOLS"))
	check_unique_folder_name.toggled.connect(_on_checkbox_toggled.bind("IMPORT_AS_UNIQUE_FOLDER_NAME"))
	check_system_trash.toggled.connect(_on_checkbox_toggled.bind("USE_SYSTEM_TRASH_ON_DELETE"))
	recent_world_num.value_changed.connect(_on_world_list_size_changed.bind("RECENT_WORLD_LIST_SIZE"))


func _on_checkbox_toggled(pressed: bool, key: String) -> void:
	LoadSettings.set_setting(key, pressed)


func _on_world_list_size_changed(value: float, key: String) -> void:
	var int_value: int = int(value)
	LoadSettings.set_setting(key, int_value)


func _on_visibility_changed() -> void:
	titlebar.text = "Settings"
	about_screen.visible = false
	GetServerConnectionInfo()


func GetServerConnectionInfo() -> void:
	no_world_loaded_label.visible = false
	world_name_label.visible = false
	ip_label.visible = false
	gamemode_label.visible = false
	game_version_label.visible = false

	if not Global.WorldLoaded:
		no_world_loaded_label.visible = true
		return

	world_name_label.visible = true
	var display_name : String = "Name: " + Global.WorldName
	var has_ip = Global.ServerIP.strip_edges() != ""

	if has_ip:
		if Global.ServerPing:
			display_name += " - Online"
			ip_label.visible = true
			ip_label.text = "Address: " + Global.ServerIP + ":" + str(Global.ServerPort)

			if Global.ServerPingData.strip_edges() != "":
				var data_segments = Global.ServerPingData.split(";")
				if data_segments.size() > 8:
					gamemode_label.visible = true
					gamemode_label.text = "Gamemode: " + data_segments[8]
					game_version_label.visible = true
					game_version_label.text = "Game version: " + data_segments[3]
				else:
					gamemode_label.visible = true
					gamemode_label.text = "Gamemode: Unknown"
					game_version_label.visible = true
					game_version_label.text = "Game version: Unknown"
		else:
			display_name += " - Offline"
			ip_label.visible = true
			ip_label.text = "Address: " + Global.ServerIP + ":" + str(Global.ServerPort)

	world_name_label.text = display_name
