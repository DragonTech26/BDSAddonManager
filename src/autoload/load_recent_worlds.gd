extends Node

const FILE_PATH := "user://recently_opened.json"

var recent_worlds: Array = []

func _ready():
	load_recent_worlds()


func load_recent_worlds() -> void:
	if not FileAccess.file_exists(FILE_PATH):
		recent_worlds = []
		save_recent_worlds()
		return

	var file: FileAccess = FileAccess.open(FILE_PATH, FileAccess.READ)
	if file == null:
		recent_worlds = []
		return

	var text: String = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)
	if typeof(parsed) == TYPE_ARRAY:
		recent_worlds = parsed
	else:
		recent_worlds = []
		save_recent_worlds()
		return

	_trim_recent_worlds()


func save_recent_worlds() -> void:
	var file: FileAccess = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(recent_worlds))
	file.close()


func add_recent_world(world_name: String, world_dir: String, rp_dir: String, bp_dir: String):
	var entry: Dictionary[Variant, Variant] = {
		"world_name": world_name,
		"location_on_disk": world_dir,
		"rp_location_on_disk": rp_dir,
		"bp_location_on_disk": bp_dir,
	}

	var index := -1
	for i in range(recent_worlds.size()):
		var item = recent_worlds[i]
		if item.location_on_disk == world_dir \
		and item.rp_location_on_disk == rp_dir \
		and item.bp_location_on_disk == bp_dir:
			index = i
			break

	if index != -1:
		recent_worlds.remove_at(index)
		print("[INFO] Removed world: " + world_name + " from recent list")

	recent_worlds.insert(0, entry)
	print("[INFO] Added recent world: " + world_name + " to list")

	_trim_recent_worlds()
	save_recent_worlds()


func _trim_recent_worlds() -> void:
	var max_list_size: int = LoadSettings.get_setting("RECENT_WORLD_LIST_SIZE")
	if recent_worlds.size() > max_list_size:
		recent_worlds = recent_worlds.slice(0, max_list_size)
