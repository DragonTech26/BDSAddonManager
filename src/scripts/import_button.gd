extends Control

var PackImporter = preload("res://src/scripts/pack_importer.gd").new()

@onready var file_picker: FileDialog = $FileDialog
@onready var background: ColorRect = $Background

var _hovered: bool = false


func _ready() -> void:
	file_picker.filters = PackedStringArray(["*.mcpack ; MCPack files", "*.mcaddon ; MCAddon files", "*.zip ; Zip archives"])
	file_picker.files_selected.connect(_on_files_selected)
	file_picker.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	Themes.theme_changed.connect(_on_theme_changed)
	set_meta("hovered", false)
	_apply_theme()


func _on_files_selected(paths: PackedStringArray) -> void:
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_WAIT)
	await get_tree().process_frame

	PackImporter.import_files(paths)
	_refresh_pack_pages()
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)


func _on_mouse_entered() -> void:
	_hovered = true
	set_meta("hovered", true)
	_apply_theme()


func _on_mouse_exited() -> void:
	_hovered = false
	set_meta("hovered", false)
	_apply_theme()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if Global.WorldLoaded:
				file_picker.popup_centered()
			else:
				AlertManager.show_alert("No world selected. Choose a world first.", Themes.get_active_palette().warning)


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


func _on_theme_changed(_theme_name: String) -> void:
	_apply_theme()


func _apply_theme() -> void:
	var palette = Themes.get_active_palette()
	if palette == null:
		return
	background.color = palette.sidebar_hover_bg if _hovered else palette.sidebar_bg
