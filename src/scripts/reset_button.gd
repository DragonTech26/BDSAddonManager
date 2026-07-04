extends Button

var _confirm_dialog: ConfirmationDialog


func _on_pressed() -> void:
	if Global.WorldLoaded:
		if _confirm_dialog == null:
			_confirm_dialog = ConfirmationDialog.new()
			_confirm_dialog.title = "Unload world?"
			add_child(_confirm_dialog)
			_confirm_dialog.confirmed.connect(_on_confirm)
		_confirm_dialog.dialog_text = "Do you want to unload world: " + Global.WorldName + "?\nAny unsaved changes will be lost."
		_confirm_dialog.popup_centered()
	else:
		AlertManager.show_alert("No world selected. Choose a world first.", Color.YELLOW)


func _on_confirm() -> void:
	var ok := _reset_globals()
	if ok:
		AlertManager.show_alert("Successfully unloaded world.", Color.GREEN)
	else:
		AlertManager.show_alert("An unexpected error has occured.", Color.CRIMSON)


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

	var settings_page = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	settings_page.GetServerConnectionInfo()

	_unfreeze_ui()
	return true


func _unfreeze_ui() -> void:
	var world_file_btn: Button = $"../../../../../../../../WorldFilesPage/VBoxContainer/HBoxContainer/WorldFolderButton"
	var rp_file_btn: Button = $"../../../../../../../../WorldFilesPage/VBoxContainer/AdvancedDropdown/Content/RPHBoxContainer/RPFolderButton"
	var bp_file_btn: Button = $"../../../../../../../../WorldFilesPage/VBoxContainer/AdvancedDropdown/Content/BPHBoxContainer/BPFolderButton"
	var validate_btn: Button = $"../../../../../../../../WorldFilesPage/VBoxContainer/HBoxContainer/ValidateButton"

	var world_path: LineEdit = $"../../../../../../../../WorldFilesPage/VBoxContainer/HBoxContainer/WorldFolderLine"
	var resource_pack_path: LineEdit = $"../../../../../../../../WorldFilesPage/VBoxContainer/AdvancedDropdown/Content/RPHBoxContainer/ResourcePackLine"
	var behavior_pack_path: LineEdit = $"../../../../../../../../WorldFilesPage/VBoxContainer/AdvancedDropdown/Content/BPHBoxContainer/BehaviorPackLine"
	var server_ip: LineEdit = $"../../../../../../../../WorldFilesPage/VBoxContainer/AdvancedDropdown/Content/ServerAddressHBoxContainer/IPLineEdit"
	var server_port: LineEdit = $"../../../../../../../../WorldFilesPage/VBoxContainer/AdvancedDropdown/Content/ServerAddressHBoxContainer/PortLineEdit"

	world_file_btn.disabled = false
	rp_file_btn.disabled = false
	bp_file_btn.disabled = false
	validate_btn.disabled = false

	world_path.editable = true
	world_path.text = ""
	resource_pack_path.editable = true
	resource_pack_path.text = ""
	behavior_pack_path.editable = true
	behavior_pack_path.text = ""
	server_ip.editable = true
	server_ip.text = ""
	server_port.editable = true
	server_port.text = ""

	var container: VBoxContainer = $"../../../../../../../../WorldFilesPage/VBoxContainer/RecentDropdown/Content/ScrollContainer/VBoxContainer"

	for slot in container.get_children():
		if slot.has_method("set_enabled"):
			slot.set_enabled(true)

	var validate_button: Button = $"../../../../../../../../WorldFilesPage/VBoxContainer/HBoxContainer/ValidateButton"
	validate_button.icon = ResourceLoader.load("res://assets/graphics/goto.svg")
	validate_button.modulate = Color.WHITE
	print("[INFO] World selection inputs have been enabled")
