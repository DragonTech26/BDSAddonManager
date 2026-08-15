extends Control

@onready var titlebar: RichTextLabel = $"../../../Topbar/Titlebar/HeaderLabel"
@onready var world_files_page: Control = %WorldFilesPage
@onready var reset_button: Button = %ResetButton
@onready var about_screen: ColorRect = $"../SettingsPage/MarginContainer/HelpScreen"
@onready var check_hide_default_packs: CheckButton = $"../SettingsPage/MarginContainer/VBoxContainer/PageContent/LeftSide/ProgramSettingsPanel/VBoxContainer/HideDefaultPacks/CheckButton"
@onready var check_hide_modifier_symbols: CheckButton = $"../SettingsPage/MarginContainer/VBoxContainer/PageContent/LeftSide/ProgramSettingsPanel/VBoxContainer/HideTextModifiers/CheckButton"
@onready var check_unique_folder_name: CheckButton = $"../SettingsPage/MarginContainer/VBoxContainer/PageContent/LeftSide/FileManagementPanel/VBoxContainer/AvoidConflicts/CheckButton"
@onready var check_system_trash: CheckButton = $"../SettingsPage/MarginContainer/VBoxContainer/PageContent/LeftSide/FileManagementPanel/VBoxContainer/UseSystemTrash/CheckButton"
@onready var recent_world_num: SpinBox = $"../SettingsPage/MarginContainer/VBoxContainer/PageContent/LeftSide/ProgramSettingsPanel/VBoxContainer/RecentWorlds/SpinBox"
@onready var theme_selector: OptionButton = $MarginContainer/VBoxContainer/PageContent/RightSide/VBoxContainer/Panel/VBoxContainer/Theme/OptionButton

@onready var no_world_loaded_label: RichTextLabel = $MarginContainer/VBoxContainer/PageContent/RightSide/VBoxContainer/ServerConnectionInfoPanel/NoWorldLoadedLabel
@onready var world_name_label: RichTextLabel = $MarginContainer/VBoxContainer/PageContent/RightSide/VBoxContainer/ServerConnectionInfoPanel/VBoxContainer/WorldNameLabel
@onready var gamemode_label: RichTextLabel = $MarginContainer/VBoxContainer/PageContent/RightSide/VBoxContainer/ServerConnectionInfoPanel/VBoxContainer/GamemodeLabel
@onready var game_version_label: RichTextLabel = $MarginContainer/VBoxContainer/PageContent/RightSide/VBoxContainer/ServerConnectionInfoPanel/VBoxContainer/GameVersionLabel
@onready var ip_label: RichTextLabel = $MarginContainer/VBoxContainer/PageContent/RightSide/VBoxContainer/ServerConnectionInfoPanel/VBoxContainer/IPLabel

var _theme_items: Dictionary = {
	0: "classic",
	1: "dark",
	2: "light",
}
var _syncing_theme_selector: bool = false


func _ready() -> void:
	check_hide_default_packs.button_pressed = LoadSettings.get_setting("HIDE_DEFAULT_SERVER_PACKS")
	check_hide_modifier_symbols.button_pressed = LoadSettings.get_setting("HIDE_TEXT_MODIFIER_SYMBOLS")
	check_unique_folder_name.button_pressed = LoadSettings.get_setting("IMPORT_AS_UNIQUE_FOLDER_NAME")
	check_system_trash.button_pressed = LoadSettings.get_setting("USE_SYSTEM_TRASH_ON_DELETE")
	recent_world_num.value = LoadSettings.get_setting("RECENT_WORLD_LIST_SIZE")
	_build_theme_selector()
	_sync_theme_selector(LoadSettings.get_setting("THEME"))

	check_hide_default_packs.toggled.connect(_on_checkbox_toggled.bind("HIDE_DEFAULT_SERVER_PACKS"))
	check_hide_modifier_symbols.toggled.connect(_on_checkbox_toggled.bind("HIDE_TEXT_MODIFIER_SYMBOLS"))
	check_unique_folder_name.toggled.connect(_on_checkbox_toggled.bind("IMPORT_AS_UNIQUE_FOLDER_NAME"))
	check_system_trash.toggled.connect(_on_checkbox_toggled.bind("USE_SYSTEM_TRASH_ON_DELETE"))
	recent_world_num.value_changed.connect(_on_world_list_size_changed.bind("RECENT_WORLD_LIST_SIZE"))
	theme_selector.item_selected.connect(_on_theme_selected)
	Themes.theme_changed.connect(_on_theme_changed)
	reset_button.reset_confirmed.connect(_on_reset_confirmed)


func _on_checkbox_toggled(pressed: bool, key: String) -> void:
	LoadSettings.set_setting(key, pressed)


func _on_world_list_size_changed(value: float, key: String) -> void:
	var int_value: int = int(value)
	LoadSettings.set_setting(key, int_value)


func _build_theme_selector() -> void:
	theme_selector.clear()
	theme_selector.add_item(" Classic")
	theme_selector.set_item_metadata(0, "classic")
	theme_selector.add_item(" Dark")
	theme_selector.set_item_metadata(1, "dark")
	theme_selector.add_item(" Light")
	theme_selector.set_item_metadata(2, "light")


func _sync_theme_selector(theme_name: Variant) -> void:
	var normalized := str(theme_name).strip_edges().to_lower()
	if normalized == "" or normalized == "null":
		normalized = "classic"

	_syncing_theme_selector = true
	for index in _theme_items.keys():
		if _theme_items[index] == normalized:
			theme_selector.select(index)
			break
	_syncing_theme_selector = false


func _on_theme_selected(index: int) -> void:
	if _syncing_theme_selector:
		return

	var theme_name: String = str(theme_selector.get_item_metadata(index))
	Themes.set_theme(theme_name)


func _on_theme_changed(theme_name: String) -> void:
	_sync_theme_selector(theme_name)


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
	var display_name : String = " Name: " + Global.WorldName
	var has_ip = Global.ServerIP.strip_edges() != ""

	if has_ip:
		if Global.ServerPing:
			display_name += " - Online"
			ip_label.visible = true
			ip_label.text = " Address: " + Global.ServerIP + ":" + str(Global.ServerPort)

			if Global.ServerPingData.strip_edges() != "":
				var data_segments = Global.ServerPingData.split(";")
				if data_segments.size() > 8:
					gamemode_label.visible = true
					gamemode_label.text = " Gamemode: " + data_segments[8]
					game_version_label.visible = true
					game_version_label.text = " Game version: " + data_segments[3]
				else:
					gamemode_label.visible = true
					gamemode_label.text = " Gamemode: Unknown"
					game_version_label.visible = true
					game_version_label.text = " Game version: Unknown"
		else:
			display_name += " - Offline"
			ip_label.visible = true
			ip_label.text = " Address: " + Global.ServerIP + ":" + str(Global.ServerPort)

	world_name_label.text = display_name


func _on_reset_confirmed() -> void:
	if _reset_globals():
		world_files_page.ResetSelectionUI()
		GetServerConnectionInfo()
		AlertManager.show_alert("Successfully unloaded world.", Themes.get_active_palette().success)
	else:
		AlertManager.show_alert("An unexpected error has occured.", Themes.get_active_palette().danger)


func _reset_globals() -> bool:
	Global.WorldPath = ""
	Global.WorldResourcePackPath = ""
	Global.WorldBehaviorPackPath = ""
	Global.WorldName = ""
	Global.RPList = []
	Global.BPList = []
	Global.WorldLoaded = false
	Global.HasUnsavedChanges = false
	Global.ServerPing = false
	Global.ServerPingData = ""
	Global.ServerIP = ""
	Global.ServerPort = 0
	return true
