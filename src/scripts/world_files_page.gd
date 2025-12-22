extends Control

var WorldValidator = preload("res://src/scripts/world_validator.gd").new()

@onready var folder_picker: FileDialog = $FolderPicker
@onready var world_path: LineEdit = $VBoxContainer/HBoxContainer/WorldFolderLine
@onready var resource_pack_path: LineEdit = $VBoxContainer/AdvancedDropdown/Content/HBoxContainer/ResourcePackLine
@onready var behavior_pack_path: LineEdit = $VBoxContainer/AdvancedDropdown/Content/HBoxContainer2/BehaviorPackLine
@onready var titlebar: RichTextLabel = $"../../../Topbar/Titlebar/HeaderLabel"


# Main functions
func _ready():
	GetRecentWorldsList()


func GetAdvancedPaths(root_path: String) -> void:
	if root_path == "":
		return
	# Go to server root directory
	var working_dir: String = DirAccess.open(root_path).get_current_dir().get_base_dir().get_base_dir()
	print("Working directory: " + working_dir)
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


func ValidatePaths():
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_WAIT)
	await get_tree().process_frame

	var world_dir: String = world_path.text.strip_edges()
	var rp_dir: String = resource_pack_path.text.strip_edges()
	var bp_dir: String = behavior_pack_path.text.strip_edges()

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

	GetWorldName()
	DisableInput()
	LoadRecentWorlds.add_recent_world(Global.WorldName, world_dir, rp_dir, bp_dir)
	GetRecentWorldsList()

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
		return

	var line: String = file.get_line()
	Global.WorldName = line.strip_edges()
	file.close()


func DisableInput():
	var world_file_btn: Button = $VBoxContainer/HBoxContainer/WorldFolderButton
	var rp_file_btn: Button = $VBoxContainer/AdvancedDropdown/Content/HBoxContainer/RPFolderButton
	var bp_file_btn: Button = $VBoxContainer/AdvancedDropdown/Content/HBoxContainer2/BPFolderButton
	var validate_btn: Button = $VBoxContainer/HBoxContainer/ValidateButton

	world_path.editable = false
	resource_pack_path.editable = false
	behavior_pack_path.editable = false

	world_file_btn.disabled = true
	rp_file_btn.disabled = true
	bp_file_btn.disabled = true
	validate_btn.disabled = true

	# Disable recent-world Edit/Remove buttons
	var container: VBoxContainer = $VBoxContainer/RecentDropdown/Content/HBoxContainer
	for slot in container.get_children():
		if slot.name.begins_with("Recent"):
			slot.set_enabled(false)


func GetRecentWorldsList():
	var rw_list: Array = LoadRecentWorlds.recent_worlds
	var container: VBoxContainer = $VBoxContainer/RecentDropdown/Content/HBoxContainer

	var slots: Array = []
	for child in container.get_children():
		if child.name.begins_with("Recent"):
			slots.append(child)

	for slot in slots:
		slot.visible = false

	for i in range(min(rw_list.size(), slots.size())):
		var data = rw_list[i]
		var slot = slots[i]

		slot.visible = true
		slot.index = i

		# Connect button signals
		if not slot.edit_pressed.is_connected(_on_recent_edit_pressed):
			slot.edit_pressed.connect(_on_recent_edit_pressed)
		if not slot.delete_pressed.is_connected(_on_recent_delete_pressed):
			slot.delete_pressed.connect(_on_recent_delete_pressed)

		slot.get_node("Background/VBoxContainer/WorldName").text = data.world_name
		slot.get_node("Background/VBoxContainer/WorldFilePath").text = data.location_on_disk


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
	ValidatePaths()


func _on_recent_edit_pressed(index: int):
	var data = LoadRecentWorlds.recent_worlds[index]
	world_path.text = data.location_on_disk
	resource_pack_path.text = data.rp_location_on_disk
	behavior_pack_path.text = data.bp_location_on_disk
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
