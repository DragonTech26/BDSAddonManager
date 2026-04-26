extends Node

func validate_all(world_dir: String, rp_dir: String, bp_dir: String) -> bool:
	# 1) Empty fields
	if world_dir == "" or rp_dir == "" or bp_dir == "":
		AlertManager.show_alert("Warning: empty paths detected!", Color.YELLOW)
		return false

	# 2) Folder names
	if rp_dir.get_file().to_lower() != "resource_packs":
		AlertManager.show_alert("Error: Invalid resource_packs directory!", Color.CRIMSON)
		return false

	if bp_dir.get_file().to_lower() != "behavior_packs":
		AlertManager.show_alert("Error: Invalid behavior_packs directory!", Color.CRIMSON)
		return false

	# 3) level.dat
	var level_dat_path := world_dir.path_join("level.dat")
	if not FileAccess.file_exists(level_dat_path):
		AlertManager.show_alert("Error: level.dat not found!", Color.CRIMSON)
		return false

	# 4) world JSON files
	if not validate_json_file(world_dir.path_join("world_resource_packs.json")):
		return false

	if not validate_json_file(world_dir.path_join("world_behavior_packs.json")):
		return false
	return true


func validate_json_file(path: String) -> bool:
	if not FileAccess.file_exists(path):
		print("JSON file missing, creating default: ", path)

		# Create the default file and write an empty JSON array
		var create_file := FileAccess.open(path, FileAccess.WRITE)
		if create_file:
			create_file.store_string("[]")
			create_file.close()
			return true
		else:
			print("Failed to create file at: ", path)
			return false

	var file := FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var err := json.parse(text)

	if err != OK:
		print("Invalid JSON in", path, "Line:", json.get_error_line())
		AlertManager.show_alert("Invalid JSON in: " + path.get_file(), Color.CRIMSON)
		return false
	return true
