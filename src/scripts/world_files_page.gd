extends Control

var WorldValidator = preload("res://src/scripts/world_validator.gd").new()

@onready var folder_picker: FileDialog = $FolderPicker
@onready var world_path: LineEdit = $VBoxContainer/HBoxContainer/WorldFolderLine
@onready var resource_pack_path: LineEdit = $VBoxContainer/AdvancedDropdown/Content/RPHBoxContainer/ResourcePackLine
@onready var behavior_pack_path: LineEdit = $VBoxContainer/AdvancedDropdown/Content/BPHBoxContainer/BehaviorPackLine
@onready var server_ip: LineEdit = $VBoxContainer/AdvancedDropdown/Content/ServerAddressHBoxContainer/IPLineEdit
@onready var server_port: LineEdit = $VBoxContainer/AdvancedDropdown/Content/ServerAddressHBoxContainer/PortLineEdit
@onready var titlebar: RichTextLabel = $"../../../Topbar/Titlebar/HeaderLabel"
@onready var recent_world_item_scene: PackedScene = preload("res://src/scenes/recent_world_item.tscn")


func _ready():
	GetRecentWorldsList()


func GetAdvancedPaths(root_path: String) -> void:
	if root_path == "":
		return
	# Go to server root directory
	var working_dir: String = DirAccess.open(root_path).get_current_dir().get_base_dir().get_base_dir()
	print("[INFO] Working directory: " + working_dir)
	if working_dir == "":
		return
	# Build expected RP/BP paths
	var rp_dir: String = working_dir.path_join("resource_packs")
	var bp_dir: String = working_dir.path_join("behavior_packs")
	# Check existence
	var rp_exists: bool = DirAccess.dir_exists_absolute(rp_dir)
	var bp_exists: bool = DirAccess.dir_exists_absolute(bp_dir)
	if rp_exists:
		resource_pack_path.text = rp_dir
	if bp_exists:
		behavior_pack_path.text = bp_dir
	# If either is missing, open the dropdown
	if !rp_exists || !bp_exists:
		$VBoxContainer/AdvancedDropdown/Content.visible = true


func ValidateIP() -> void:
	var target_ip: String = server_ip.text.strip_edges()
	var port_text: String = server_port.text.strip_edges()

	# Check for empty fields
	if target_ip.is_empty():
		print("[NETWORK] No IP address provided. Skipping network check.")
		return
	if port_text.is_empty():
		print("[NETWORK] No port provided. Skipping network check.")
		return

	# Port Validation
	if not port_text.is_valid_int():
		AlertManager.show_alert("Invalid Port: Must contain only numbers!", Color.RED)
		return

	var target_port = port_text.to_int()
	if target_port < 1 or target_port > 65535:
		AlertManager.show_alert("Invalid Port: Must be between 1 and 65535!", Color.RED)
		return

	# IP Validation
	if not target_ip.is_valid_ip_address():
		AlertManager.show_alert("Invalid format! Enter a valid IP (e.g. 127.0.0.1).", Color.RED)
		return

	CheckServerPing.ping_bedrock_server(target_ip, target_port)


func ValidatePaths():
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_WAIT)
	await get_tree().process_frame

	var world_dir: String = world_path.text.strip_edges()
	var rp_dir: String = resource_pack_path.text.strip_edges()
	var bp_dir: String = behavior_pack_path.text.strip_edges()
	var ip_address: String = server_ip.text.strip_edges()
	var port: String = server_port.text.strip_edges()

	# If user pasted only the world path, try auto-detect first
	if world_dir != "" and (rp_dir == "" or bp_dir == ""):
		GetAdvancedPaths(world_dir)
		rp_dir = resource_pack_path.text.strip_edges()
		bp_dir = behavior_pack_path.text.strip_edges()

	if not WorldValidator.validate_all(world_dir, rp_dir, bp_dir):
		return false

	# Change icon to show valid paths
	var validate_button: Button = $VBoxContainer/HBoxContainer/ValidateButton
	validate_button.icon = ResourceLoader.load("res://assets/graphics/check.svg")
	validate_button.modulate = Color.GREEN

	# Set global variables
	Global.WorldPath = world_dir
	Global.WorldResourcePackPath = rp_dir
	Global.WorldBehaviorPackPath = bp_dir
	Global.ServerIP = ip_address
	Global.ServerPort = int(port)

	GetWorldName()
	LoadRecentWorlds.add_recent_world(Global.WorldName, world_dir, rp_dir, bp_dir, ip_address, port)
	GetRecentWorldsList()
	DisableInput()

	var parser: JsonParser = JsonParser.new()
	parser.ReadData()
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
	Global.WorldLoaded = true
	AlertManager.show_alert("Successfully loaded world: " + Global.WorldName, Color.GREEN)


func GetWorldName() -> void:
	var world_dir: String = Global.WorldPath
	var name_file: String = world_dir.path_join("levelname.txt")

	if not FileAccess.file_exists(name_file):
		Global.WorldName = "Unknown"
		return

	var file: FileAccess = FileAccess.open(name_file, FileAccess.READ)
	if file == null:
		Global.WorldName = "Unknown"
		print("[WARN] Unable to read world name")
		return

	var line: String = file.get_line()
	Global.WorldName = line.strip_edges()
	file.close()


func DisableInput():
	var world_file_btn: Button = $VBoxContainer/HBoxContainer/WorldFolderButton
	var rp_file_btn: Button = $VBoxContainer/AdvancedDropdown/Content/RPHBoxContainer/RPFolderButton
	var bp_file_btn: Button = $VBoxContainer/AdvancedDropdown/Content/BPHBoxContainer/BPFolderButton
	var validate_btn: Button = $VBoxContainer/HBoxContainer/ValidateButton

	world_path.editable = false
	resource_pack_path.editable = false
	behavior_pack_path.editable = false
	server_ip.editable = false
	server_port.editable = false

	world_file_btn.disabled = true
	rp_file_btn.disabled = true
	bp_file_btn.disabled = true
	validate_btn.disabled = true

	# Disable recent-world buttons
	var recent_container: VBoxContainer = $VBoxContainer/RecentDropdown/Content/ScrollContainer/VBoxContainer

	for slot in recent_container.get_children():
		if slot.has_method("set_enabled"):
			slot.set_enabled(false)

	print("[INFO] World selection inputs have been disabled")


func ResetSelectionUI() -> void:
	var world_file_btn: Button = $VBoxContainer/HBoxContainer/WorldFolderButton
	var rp_file_btn: Button = $VBoxContainer/AdvancedDropdown/Content/RPHBoxContainer/RPFolderButton
	var bp_file_btn: Button = $VBoxContainer/AdvancedDropdown/Content/BPHBoxContainer/BPFolderButton
	var validate_btn: Button = $VBoxContainer/HBoxContainer/ValidateButton

	var world_path_edit: LineEdit = $VBoxContainer/HBoxContainer/WorldFolderLine
	var resource_pack_path_edit: LineEdit = $VBoxContainer/AdvancedDropdown/Content/RPHBoxContainer/ResourcePackLine
	var behavior_pack_path_edit: LineEdit = $VBoxContainer/AdvancedDropdown/Content/BPHBoxContainer/BehaviorPackLine
	var server_ip_edit: LineEdit = $VBoxContainer/AdvancedDropdown/Content/ServerAddressHBoxContainer/IPLineEdit
	var server_port_edit: LineEdit = $VBoxContainer/AdvancedDropdown/Content/ServerAddressHBoxContainer/PortLineEdit

	world_file_btn.disabled = false
	rp_file_btn.disabled = false
	bp_file_btn.disabled = false
	validate_btn.disabled = false

	world_path_edit.editable = true
	world_path_edit.text = ""
	resource_pack_path_edit.editable = true
	resource_pack_path_edit.text = ""
	behavior_pack_path_edit.editable = true
	behavior_pack_path_edit.text = ""
	server_ip_edit.editable = true
	server_ip_edit.text = ""
	server_port_edit.editable = true
	server_port_edit.text = ""

	var container: VBoxContainer = $VBoxContainer/RecentDropdown/Content/ScrollContainer/VBoxContainer

	for slot in container.get_children():
		if slot.has_method("set_enabled"):
			slot.set_enabled(true)

	validate_btn.icon = ResourceLoader.load("res://assets/graphics/goto.svg")
	validate_btn.modulate = Color.WHITE
	print("[INFO] World selection inputs have been reset")


func GetRecentWorldsList():
	var rw_list: Array = LoadRecentWorlds.recent_worlds
	var container: VBoxContainer = $VBoxContainer/RecentDropdown/Content/ScrollContainer/VBoxContainer
	var label: RichTextLabel = $VBoxContainer/RecentDropdown/Content/MessageLabel

	for child in container.get_children():
		child.queue_free()

	for i in rw_list.size():
		var data = rw_list[i]
		var slot = recent_world_item_scene.instantiate()

		container.add_child(slot)
		slot.index = i

		# Connect signals once per instance
		slot.edit_pressed.connect(_on_recent_edit_pressed)
		slot.delete_pressed.connect(_on_recent_delete_pressed)

		slot.get_node("Background/VBoxContainer/WorldName").text = data.world_name
		slot.get_node("Background/VBoxContainer/WorldFilePath").text = data.location_on_disk

	if rw_list.size() <= 0:
		var rw_list_size = LoadSettings.get_setting("RECENT_WORLD_LIST_SIZE")
		if rw_list_size == 0:
			label.text = "Recent worlds list has been disabled"
		else: label.text = "Nothing here...yet!"
		label.visible = true
	else:
		label.visible = false


# UI Signal functions
func _on_world_folder_button_pressed():
	folder_picker.open_for(world_path)
	var result = await folder_picker.dir_selected
	GetAdvancedPaths(result)


func _on_rp_folder_button_pressed():
	folder_picker.open_for(resource_pack_path)


func _on_bp_folder_button_pressed():
	folder_picker.open_for(behavior_pack_path)


func _on_validate_button_pressed():
	ValidateIP()
	ValidatePaths()


func _on_recent_edit_pressed(index: int):
	var data = LoadRecentWorlds.recent_worlds[index]
	world_path.text = data.get("location_on_disk", "")
	resource_pack_path.text = data.get("rp_location_on_disk", "")
	behavior_pack_path.text = data.get("bp_location_on_disk", "")
	server_ip.text = data.get("server_ip_on_disk", "")
	server_port.text = data.get("server_port_on_disk", "")
	ValidateIP()
	ValidatePaths()


func _on_recent_delete_pressed(index: int):
	LoadRecentWorlds.recent_worlds.remove_at(index)
	LoadRecentWorlds.save_recent_worlds()
	GetRecentWorldsList()


func _on_visibility_changed() -> void:
	if titlebar == null:
		await ready
		titlebar.text = "World Files"
	titlebar.text = "World Files"
