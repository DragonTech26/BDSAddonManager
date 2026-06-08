extends Control

var PackImporter = preload("res://src/scripts/pack_importer.gd").new()

@onready var file_picker: FileDialog = $FileDialog


func _ready() -> void:
	file_picker.filters = PackedStringArray(["*.mcpack ; MCPack files", "*.mcaddon ; MCAddon files", "*.zip ; Zip archives"])
	file_picker.files_selected.connect(_on_files_selected)
	file_picker.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)


func _on_files_selected(paths: PackedStringArray) -> void:
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_WAIT)
	await get_tree().process_frame

	PackImporter.import_files(paths)
	_refresh_pack_pages()
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)


func _on_mouse_entered() -> void:
	$Background.color = Color("#3B4A5B")


func _on_mouse_exited() -> void:
	$Background.color = Color("#363D4A")


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if Global.WorldLoaded:
				file_picker.popup_centered()
			else:
				AlertManager.show_alert("No world selected. Choose a world first.", Color.YELLOW)


func _refresh_pack_pages() -> void:
	# Re-parse manifests to update Global.RPList and Global.BPList
	var parser := JsonParser.new()
	parser.ReadData()
	print("[INFO] New pack(s) imported. Global lists refreshed")

	# Refresh Resource Packs page
	var rp_page: Node = $"../../../../Body/Pages/MarginContainer/ResourcePacksPage"
	if rp_page and rp_page.has_method("load_packs"):
		rp_page.load_packs(Global.RPList)

	# Refresh Behavior Packs page
	var bp_page: Node = $"../../../../Body/Pages/MarginContainer/BehaviorPacksPage"
	if bp_page and bp_page.has_method("load_packs"):
		bp_page.load_packs(Global.BPList)
