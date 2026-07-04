extends Control

var _confirm_dialog: ConfirmationDialog


func _on_mouse_entered() -> void:
	$Background.color = "#3B4A5B"


func _on_mouse_exited() -> void:
	$Background.color = "#363D4A"


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if Global.WorldPath == "" or Global.WorldLoaded == false:
				AlertManager.show_alert("No world selected. Choose a world first.", Color.YELLOW)
				return

			CheckServerPing.ping_bedrock_server(Global.ServerIP, Global.ServerPort)

			if _confirm_dialog == null:
				_confirm_dialog = ConfirmationDialog.new()
				_confirm_dialog.title = "Save changes?"
				add_child(_confirm_dialog)
				_confirm_dialog.confirmed.connect(_on_confirm_save)

			if Global.ServerPing == false:
				_confirm_dialog.dialog_text = "Apply active packs to this world?\nThis will overwrite the currently active packs."
			else:
				_confirm_dialog.dialog_text = "Apply active packs to this world?\nThis will overwrite the currently active packs.\nWarning: Server is online! Here be dragons!"
			_confirm_dialog.popup_centered()


func _on_confirm_save() -> void:
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_WAIT)
	await get_tree().process_frame

	var ok := _save_active_packs()
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
	if ok:
		AlertManager.show_alert("Saved world: " + Global.WorldName, Color.GREEN)
		Global.HasUnsavedChanges = false
	else:
		AlertManager.show_alert("Failed to save packs for: " + Global.WorldName, Color.CRIMSON)
		Global.HasUnsavedChanges = true

func _save_active_packs() -> bool:
	# Prefer live UI state when available, otherwise fall back to data in Global.* lists.
	var rp_container_path := "../../../../Body/Pages/MarginContainer/ResourcePacksPage/ScrollContainer/VBoxContainer"
	var bp_container_path := "../../../../Body/Pages/MarginContainer/BehaviorPacksPage/ScrollContainer/VBoxContainer"

	var rp_container := get_node_or_null(rp_container_path)
	var bp_container := get_node_or_null(bp_container_path)

	var rp_ui_map := _build_ui_state_map(rp_container) # pack_id -> {active: bool, subpack: String}
	var bp_ui_map := _build_ui_state_map(bp_container)

	# Build arrays for saving using merged UI + Global state
	var rp_array: Array = _collect_from_globals(Global.RPList, rp_ui_map)
	var bp_array: Array = _collect_from_globals(Global.BPList, bp_ui_map)

	# Persist UI choices back into in-memory Global lists so page reloads keep the state
	_apply_ui_to_globals(Global.RPList, rp_ui_map)
	_apply_ui_to_globals(Global.BPList, bp_ui_map)

	# Write files
	var rp_path: String = Global.WorldPath.path_join("world_resource_packs.json")
	var bp_path: String = Global.WorldPath.path_join("world_behavior_packs.json")

	var ok1 := _write_json_array(rp_path, rp_array)
	var ok2 := _write_json_array(bp_path, bp_array)
	return ok1 and ok2


func _build_ui_state_map(container: Node) -> Dictionary:
	# Returns: { pack_id: {"active": bool, "subpack": String} }
	var map := { }
	if container == null:
		return map
	for c in container.get_children():
		if not c.has_method("get_pack_data"):
			continue
		var d = c.get_pack_data()
		var state := {
			"active": false,
			"subpack": "",
		}
		# Read checkbox directly from node tree for robustness
		var cb: CheckBox = c.get_node_or_null("MarginContainer/HBoxContainer/CheckBox")
		if cb != null:
			state["active"] = cb.button_pressed
		# Read dropdown selection
		var dd: OptionButton = c.get_node_or_null("MarginContainer/HBoxContainer/SubpackDropdown")
		if dd != null and dd.visible and not dd.disabled and d.subpacks.size() > 0:
			var sel_idx: int = dd.selected
			if sel_idx >= 0 and sel_idx < d.subpacks.size():
				var sp = d.subpacks[sel_idx]
				if typeof(sp) == TYPE_DICTIONARY and sp.has("folder_name"):
					state["subpack"] = str(sp.folder_name)
		map[str(d.pack_id)] = state
	return map


func _collect_from_globals(global_list: Array, ui_map: Dictionary) -> Array:
	var result: Array = []
	for d in global_list:
		var pack_id := str(d.pack_id)
		var active: bool = d.is_active
		var sub: String = d.active_subpack
		if ui_map.has(pack_id):
			var ui_state = ui_map[pack_id]
			if typeof(ui_state) == TYPE_DICTIONARY:
				if ui_state.has("active"):
					active = bool(ui_state["active"])
				if ui_state.has("subpack"):
					sub = str(ui_state["subpack"])
		if not active:
			continue
		var entry := {
			"pack_id": pack_id,
			"version": d.version,
		}
		if typeof(sub) == TYPE_STRING and sub != "":
			entry["subpack"] = sub
		result.append(entry)
	return result


func _apply_ui_to_globals(global_list: Array, ui_map: Dictionary) -> void:
	# Merge UI state into the provided Global list so subsequent page reloads reflect the latest choices
	for d in global_list:
		var pack_id := str(d.pack_id)
		var active: bool = d.is_active
		var sub: String = d.active_subpack
		if ui_map.has(pack_id):
			var ui_state = ui_map[pack_id]
			if typeof(ui_state) == TYPE_DICTIONARY:
				if ui_state.has("active"):
					active = bool(ui_state["active"])
				if ui_state.has("subpack"):
					sub = str(ui_state["subpack"])
		d.is_active = active
		d.active_subpack = sub if typeof(sub) == TYPE_STRING else ""


func _write_json_array(path: String, data: Array) -> bool:
	var json_text := JSON.stringify(data, "\t")
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(json_text)
	f.close()
	print("[INFO] Successfully wrote new world pack json files")
	return true
