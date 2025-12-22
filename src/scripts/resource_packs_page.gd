extends Control

var PackItemScene: PackedScene = preload("res://src/scenes/pack_item.tscn")

@onready var list_container: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var info_label: Label = $Label
@onready var titlebar: RichTextLabel = $"../../../Topbar/Titlebar/HeaderLabel"


func load_packs(packs):
	print("load_packs called. count = ", packs.size())
	for c in list_container.get_children():
		c.queue_free()

	# Optionally hide default server packs
	var show_packs = packs
	if LoadSettings.get_setting("HIDE_DEFAULT_SERVER_PACKS"):
		var filtered: Array = []
		var hidden_prefixes: Array = [
			"resourcepack.",
			"@minecraft",
			"experimental",
		]
		for p in packs:
			var n: String = str(p.name).to_lower()
			var should_hide := false
			for prefix in hidden_prefixes:
				if n.begins_with(prefix):
					should_hide = true
					break
			if should_hide:
				continue
			filtered.append(p)
		show_packs = filtered

	for pack in show_packs:
		var item: Node = PackItemScene.instantiate()
		list_container.add_child(item)
		item.setup(pack)

	# After all items are added, refresh button states so first/last are correct
	for c in list_container.get_children():
		if c.has_method("_update_buttons_state"):
			c._update_buttons_state()

	# Hide the label if there is a world name, which should mean there is a loaded world.
	if Global.WorldLoaded:
		if show_packs.size() >= 1:
			info_label.visible = false
		else:
			info_label.text = "No resource packs detected :("
			info_label.visible = true
	else:
		info_label.visible = true
		info_label.text = "Select a world first!"


func _on_visibility_changed():
	if is_visible():
		load_packs(Global.RPList) # Populate with manifest data when page becomes visible
		titlebar.text = "Resource Packs"
