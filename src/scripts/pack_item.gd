extends PanelContainer

var pack_data
var _delete_dialog: ConfirmationDialog
var _error_dialog: AcceptDialog

@onready var up_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/UpButton
@onready var down_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/DownButton
@onready var icon: TextureRect = $MarginContainer/HBoxContainer/PackIcon
@onready var pack_version_label: RichTextLabel = $MarginContainer/HBoxContainer/VersionLabel
@onready var name_label: RichTextLabel = $MarginContainer/HBoxContainer/NameLabel
@onready var check_box: CheckBox = $MarginContainer/HBoxContainer/CheckBox
@onready var dropdown: OptionButton = $MarginContainer/HBoxContainer/SubpackDropdown
@onready var delete_btn: Button = $MarginContainer/HBoxContainer/DeleteButton
@onready var dependency_alert: TextureRect = $MarginContainer/HBoxContainer/DependencyInfo


func setup(data):
	pack_data = data

	name_label.text = data.name
	pack_version_label.text = "v" + String(".").join(data.version)
	icon.tooltip_text = data.description

	# Use pre-loaded icon from manifest data
	if data.pack_icon != null:
		icon.texture = data.pack_icon

	# Checkbox
	check_box.set_block_signals(true)
	check_box.button_pressed = data.is_active
	check_box.set_block_signals(false)

	# Dependency check
	if data.dependencies.size() > 0:
		dependency_alert.visible = true
	else:
		dependency_alert.visible = false

	# Dropdown
	dropdown.clear()
	if data.subpacks.size() > 0:
		dropdown.disabled = false
		for i in range(data.subpacks.size()):
			var s = data.subpacks[i]
			var full_name: String = s.name
			var truncated: String = _truncate_text(full_name, 32) # limit display to 32 chars
			dropdown.add_item(truncated)
			dropdown.set_item_tooltip(i, full_name) # full name on hover

		# Calculate selected index based on active_subpack
		var selected_index: int = 0
		for i in range(data.subpacks.size()):
			if data.subpacks[i]["folder_name"] == data.active_subpack:
				selected_index = i
				break
		dropdown.set_block_signals(true)
		dropdown.select(selected_index)
		dropdown.set_block_signals(false)
	else:
		dropdown.visible = false

	# Initialize button enabled/disabled based on position
	# Defer so it runs after all items are added to the container
	call_deferred("_update_buttons_state")


func get_pack_data():
	return pack_data


func _truncate_text(text: String, max_chars: int) -> String:
	if text.length() > max_chars:
		return text.substr(0, max_chars) + "..."
	return text


func _on_check_box_toggled(toggled_on: bool) -> void:
	# Persist active state immediately so switching pages keeps the state even without saving
	if pack_data == null:
		return
	pack_data.is_active = toggled_on
	_persist_state_to_global()


func _on_subpack_dropdown_item_selected(index: int) -> void:
	# Persist selected subpack immediately
	if pack_data == null:
		return
	var sel_folder := ""
	if typeof(pack_data.subpacks) == TYPE_ARRAY and index >= 0 and index < pack_data.subpacks.size():
		var sp = pack_data.subpacks[index]
		if typeof(sp) == TYPE_DICTIONARY and sp.has("folder_name"):
			sel_folder = str(sp.folder_name)
	pack_data.active_subpack = sel_folder
	_persist_state_to_global()


func _on_delete_button_pressed():
	# Show a confirmation dialog before deleting from disk
	if _delete_dialog == null:
		_delete_dialog = ConfirmationDialog.new()
		_delete_dialog.title = "Delete pack?"
		add_child(_delete_dialog)
		_delete_dialog.confirmed.connect(_on_confirm_delete)

	if LoadSettings.get_setting("USE_SYSTEM_TRASH_ON_DELETE"):
		_delete_dialog.dialog_text = "Are you sure you want to delete\n'%s'?" % str(pack_data.name)
	else:
		_delete_dialog.dialog_text = "Are you sure you want to permanently delete\n'%s' from file system?" % str(pack_data.name)

	_delete_dialog.popup_centered()


func _on_confirm_delete() -> void:
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_WAIT)
	await get_tree().process_frame

	var base_path := ""
	if str(pack_data.type) == "behavior":
		base_path = Global.WorldBehaviorPackPath
	else:
		base_path = Global.WorldResourcePackPath

	var target_dir := base_path.path_join(str(pack_data.pack_folder))
	var success := false

	# Try system trash
	if LoadSettings.get_setting("USE_SYSTEM_TRASH_ON_DELETE"):
		if OS.move_to_trash(target_dir) == OK:
			success = true

	# Manual Recursion (Slower Fallback)
	if not success:
		success = _delete_directory_recursive(target_dir)

	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)

	if success:
		var container := get_parent()
		if container != null:
			container.remove_child(self)
			_sync_global_order(container)
			_update_buttons_for_all(container)
		queue_free()
		Global.HasUnsavedChanges = true
	else:
		if _error_dialog == null:
			_error_dialog = AcceptDialog.new()
			_error_dialog.title = "Delete failed"
			add_child(_error_dialog)
		_error_dialog.dialog_text = "Could not delete folder:\n%s" % target_dir
		_error_dialog.popup_centered()


func _delete_directory_recursive(path: String) -> bool:
	if not DirAccess.dir_exists_absolute(path):
		return true

	var d := DirAccess.open(path)
	if d == null:
		return false

	var success := true
	d.list_dir_begin()
	var filename := d.get_next()
	while filename != "":
		if not filename.begins_with("."):
			var full := path.path_join(filename)
			if d.current_is_dir():
				if not _delete_directory_recursive(full):
					success = false
			else:
				var err := DirAccess.remove_absolute(full)
				if err != OK:
					success = false
		filename = d.get_next()
	d.list_dir_end()

	var err2 := DirAccess.remove_absolute(path)
	if err2 != OK:
		success = false
	return success


func _on_up_button_pressed() -> void:
	_move_item(-1)


func _on_down_button_pressed() -> void:
	_move_item(1)


func _on_pack_icon_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var base_path := ""
		if str(pack_data.type) == "behavior":
			base_path = Global.WorldBehaviorPackPath
		else:
			base_path = Global.WorldResourcePackPath
		var target_dir := base_path.path_join(str(pack_data.pack_folder))
		OS.shell_open(target_dir)


func _move_item(delta: int) -> void:
	var container := get_parent()
	if container == null:
		return

	var from_idx := get_index()
	var to_idx := from_idx + delta
	var last_idx := container.get_child_count() - 1

	if to_idx < 0 or to_idx > last_idx:
		return

	container.move_child(self, to_idx)
	_sync_global_order(container)
	_update_buttons_for_all(container)

	Global.HasUnsavedChanges = true


func _sync_global_order(container: Node) -> void:
	# Rebuild the corresponding Global list according to current visual order.
	# Determine which list to update based on this item's pack type.
	var new_order: Array = []
	var list_type: String = ""

	# Prefer the current item's type as the source of truth
	if pack_data != null:
		list_type = str(pack_data.type)

	for c in container.get_children():
		if c.has_method("get_pack_data"):
			var d = c.get_pack_data()
			new_order.append(d)

	# Update the correct global list
	if list_type == "behavior":
		Global.BPList = new_order
	else:
		# Default/fallback to resource packs
		Global.RPList = new_order


func _update_buttons_for_all(container: Node) -> void:
	var count := container.get_child_count()
	for i in count:
		var c: Node = container.get_child(i)
		if c.has_method("_update_buttons_state"):
			c._update_buttons_state()


func _update_buttons_state() -> void:
	var container := get_parent()
	if container == null:
		return
	var idx := get_index()
	var last_idx := container.get_child_count() - 1
	up_button.disabled = idx <= 0
	down_button.disabled = idx >= last_idx


# Persist current pack_data.is_active and pack_data.active_subpack into the proper Global list
func _persist_state_to_global() -> void:
	if pack_data == null:
		return
	var target := []
	var ptype := str(pack_data.type)
	if ptype == "behavior":
		target = Global.BPList
	else:
		target = Global.RPList
	for i in target.size():
		var d = target[i]
		if d != null and str(d.pack_id) == str(pack_data.pack_id):
			d.is_active = bool(pack_data.is_active)
			d.active_subpack = str(pack_data.active_subpack) if typeof(pack_data.active_subpack) == TYPE_STRING else ""
			break
	Global.HasUnsavedChanges = true
