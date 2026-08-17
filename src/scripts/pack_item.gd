extends PanelContainer

const DialogBoxScene = preload("res://src/scenes/dialog_box.tscn")

var pack_data
var _error_dialog: AcceptDialog
var _theme_connected: bool = false

@onready var up_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/UpButton
@onready var down_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/DownButton
@onready var icon: TextureRect = $MarginContainer/HBoxContainer/PackIcon
@onready var pack_version_label: RichTextLabel = $MarginContainer/HBoxContainer/VersionLabel
@onready var name_label: RichTextLabel = $MarginContainer/HBoxContainer/NameLabel
@onready var check_box: CheckBox = $MarginContainer/HBoxContainer/CheckBox
@onready var dropdown: OptionButton = $MarginContainer/HBoxContainer/SubpackDropdown
@onready var delete_btn: Button = $MarginContainer/HBoxContainer/DeleteButton
@onready var dependency_alert: TextureRect = $MarginContainer/HBoxContainer/DependencyInfo


func _ready() -> void:
	add_to_group("pack_item_panel")
	if not _theme_connected:
		Themes.theme_changed.connect(_on_theme_changed)
		_theme_connected = true
	call_deferred("apply_theme")


func setup(data):
	pack_data = data

	name_label.text = data.name
	pack_version_label.text = "v" + String(".").join(data.version)
	name_label.tooltip_text = _wrap_text(data.description)

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
			dropdown.add_item(" " + truncated)
			dropdown.set_item_tooltip(i, _wrap_text(full_name)) # full name on hover

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
	call_deferred("apply_theme")


func get_pack_data():
	return pack_data


func apply_theme() -> void:
	Themes.apply_to(self)


func _truncate_text(text: String, max_chars: int) -> String:
	if text.length() > max_chars:
		return text.substr(0, max_chars) + "..."
	return text


func _wrap_text(text: String, max_chars_per_line: int = 60) -> String:
	var words := text.split(" ")
	var wrapped := ""
	var line_length := 0

	for word in words:
		# +1 accounts for the space that would precede this word on the current line
		if line_length > 0 and line_length + 1 + word.length() > max_chars_per_line:
			wrapped += "\n"
			line_length = 0
		elif line_length > 0:
			wrapped += " "
			line_length += 1

		wrapped += word
		line_length += word.length()

	return wrapped


func _on_check_box_toggled(toggled_on: bool) -> void:
	# Persist active state immediately so switching pages keeps the state even without saving
	if pack_data == null:
		return
	pack_data.is_active = toggled_on
	_persist_state_to_global()
	print("[INFO] Pack '%s' has been toggled %s" % [pack_data.name, "ON" if toggled_on else "OFF"])


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
	print("[INFO] Subpack changed to '" + sel_folder + "' for pack '" + pack_data.name + "'")


func _on_delete_button_pressed() -> void:
	# Show a confirmation dialog before deleting from disk
	if pack_data == null:
		return

	print("[ALERT] Requesting delete for pack '%s' (Folder: %s)" % [pack_data.name, pack_data.pack_folder])

	var message: String
	if LoadSettings.get_setting("USE_SYSTEM_TRASH_ON_DELETE"):
		message = "Are you sure you want to delete\n'%s'?" % str(pack_data.name)
	else:
		message = "Are you sure you want to permanently delete\n'%s' from file system?" % str(pack_data.name)

	var dialog := DialogBoxScene.instantiate()
	get_tree().current_scene.add_child(dialog)
	dialog.setup("Delete pack?", message, "Delete", "Cancel")

	var result: DialogBox.Result = await dialog.finished
	if result == DialogBox.Result.ACCEPT:
		_on_confirm_delete()


func _on_confirm_delete() -> void:
	print("[ALERT] Confirmed delete for pack '%s'" % pack_data.name)
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_WAIT)
	await get_tree().process_frame

	var base_path := ""
	if str(pack_data.type) == "behavior":
		base_path = Global.WorldBehaviorPackPath
	else:
		base_path = Global.WorldResourcePackPath

	var target_dir := base_path.path_join(str(pack_data.pack_folder))
	var success := false
	print("[FILE] Target directory: %s" % target_dir)

	# Try system trash
	if LoadSettings.get_setting("USE_SYSTEM_TRASH_ON_DELETE"):
		print("[FILE] Attempting move to system trash...")
		if OS.move_to_trash(target_dir) == OK:
			print("[FILE] Successfully moved to trash.")
			success = true
		else:
			print("[FILE] Move to trash failed. Falling back to alternative system")

	# Manual Recursion (Slower Fallback)
	if not success:
		print("[FILE] Attempting recursive deletion...")
		success = _delete_directory_recursive(target_dir)

	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)

	if success:
		print("[FILE] Successfully deleted pack '%s'" % pack_data.name)
		var container := get_parent()
		if container != null:
			container.remove_child(self)
			_sync_global_order(container)
			_update_buttons_for_all(container)
		queue_free()
		Global.HasUnsavedChanges = true
	else:
		print("[ERROR] FAILED to delete '%s'" % target_dir)
		if _error_dialog == null:
			_error_dialog = AcceptDialog.new()
			_error_dialog.title = "Delete failed"
			add_child(_error_dialog)
		_error_dialog.dialog_text = "Could not delete folder:\n%s" % target_dir
		_error_dialog.popup_centered()


func _delete_directory_recursive(path: String) -> bool:
	print("[FILE] Entering directory: %s" % path)
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
				print("[FILE] Removing file: %s" % full)
				var err := DirAccess.remove_absolute(full)
				if err != OK:
					print("[FILE] Failed removing file: %s" % full)
					success = false
		filename = d.get_next()
	d.list_dir_end()

	print("[FILE] Removing directory: %s" % path)
	var err2 := DirAccess.remove_absolute(path)
	if err2 != OK:
		print("[FILE] Failed removing directory: %s" % path)
		success = false
	return success


func _on_up_button_pressed() -> void:
	_move_item(-1)


func _on_down_button_pressed() -> void:
	_move_item(1)


func _on_theme_changed(_theme_name: String) -> void:
	apply_theme()


func _on_delete_button_mouse_entered() -> void:
	$MarginContainer/HBoxContainer/DeleteButton/Icon.modulate = Themes.get_active_palette().danger


func _on_delete_button_mouse_exited() -> void:
	$MarginContainer/HBoxContainer/DeleteButton/Icon.modulate = Themes.get_active_palette().icon_color_override


func _on_up_button_mouse_entered() -> void:
	if not up_button.disabled:
		up_button.get_node("Icon").modulate = Themes.get_active_palette().icon_hover_color


func _on_up_button_mouse_exited() -> void:
	if not up_button.disabled:
		up_button.get_node("Icon").modulate = Themes.get_active_palette().icon_color_override


func _on_down_button_mouse_entered() -> void:
	if not down_button.disabled:
		down_button.get_node("Icon").modulate = Themes.get_active_palette().icon_hover_color


func _on_down_button_mouse_exited() -> void:
	if not down_button.disabled:
		down_button.get_node("Icon").modulate = Themes.get_active_palette().icon_color_override


func _on_pack_icon_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var base_path := ""
		if str(pack_data.type) == "behavior":
			base_path = Global.WorldBehaviorPackPath
		else:
			base_path = Global.WorldResourcePackPath

		var target_dir := base_path.path_join(str(pack_data.pack_folder))
		if OS.get_name() == "Windows":
			if target_dir.begins_with("//"):
				target_dir = "\\\\" + target_dir.substr(2).replace("/", "\\")
			else:
				target_dir = target_dir.replace("/", "\\")

		OS.shell_open(target_dir)
		print("[INFO] Opened file manager at: " + target_dir)


func _move_item(delta: int) -> void:
	var container := get_parent()
	if container == null:
		return

	var from_idx := get_index()
	var to_idx := from_idx + delta
	var last_idx := container.get_child_count() - 1

	if to_idx < 0 or to_idx > last_idx:
		return

	var pack_type := str(pack_data.type).capitalize()
	print("[INFO] Moving %s pack '%s' from index %d to %d" % [pack_type, pack_data.name, from_idx, to_idx])

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

	#print("[DEBUG] Rebuilding global order for type: %s" % list_type)
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

	#print("[DEBUG] Global order sync complete.")


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
	apply_theme()

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
