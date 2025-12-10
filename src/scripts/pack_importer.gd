extends Node


func import_files(paths: PackedStringArray) -> void:
	for path in paths:
		_process_single_file(path)


func _process_single_file(path: String) -> void:
	# Step 1: Determine extension and route accordingly
	var ext := path.get_extension().to_lower()
	if ext == "mcaddon":
		_process_mcaddon(path)
		return

	# Step 1b: Make sure the file extension is valid for direct import
	if not _is_valid_extension(path):
		print("PackImporter: Invalid extension for ", path)
		return

	# Step 2: Unzip them in a temp folder
	var temp_path: String = _unzip_to_temp(path)
	if temp_path.is_empty():
		print("PackImporter: Failed to unzip ", path)
		return

	# Step 3: Find the manifest.json file
	var manifest_path: String = _find_manifest_in_path(temp_path)
	if manifest_path.is_empty():
		print("PackImporter: No manifest found in ", path)
		_cleanup_temp(temp_path)
		return

	# Step 4: Parse and copy based on type
	_parse_and_distribute(manifest_path, temp_path, path.get_file().get_basename())

	# Cleanup
	_cleanup_temp(temp_path)


func _is_valid_extension(path: String) -> bool:
	var ext: String = path.get_extension().to_lower()
	return ext == "zip" or ext == "mcpack" or ext == "mcaddon"


func _process_mcaddon(file_path: String) -> void:
	# Unzip the .mcaddon into a temp directory
	var temp_root := _unzip_to_temp(file_path)
	if temp_root.is_empty():
		print("PackImporter: Failed to unzip mcaddon: ", file_path)
		return

	# Scan the extracted content for files or folders
	var dir := DirAccess.open(temp_root)
	if not dir:
		print("PackImporter: Could not open extracted mcaddon directory")
		_cleanup_temp(temp_root)
		return

	var found_any := false
	dir.list_dir_begin()
	var item := dir.get_next()

	while item != "":
		if not item.begins_with("."):
			var abs_item := temp_root.path_join(item)

			if FileAccess.file_exists(abs_item):
				var ext := abs_item.get_extension().to_lower()
				# Nested .mcpack
				if ext == "mcpack":
					found_any = true
					_process_single_file(abs_item)

			elif DirAccess.dir_exists_absolute(abs_item):
				# Folder pack → check for manifest.json
				var manifest := abs_item.path_join("manifest.json")
				if FileAccess.file_exists(manifest):
					found_any = true
					_parse_and_distribute(manifest, abs_item, item)

		item = dir.get_next()

	if not found_any:
		print("PackImporter: No valid mcpacks or pack folders inside mcaddon")

	_cleanup_temp(temp_root)


func _unzip_to_temp(file_path: String) -> String:
	var reader := ZIPReader.new()
	if reader.open(file_path) != OK:
		return ""

	# Create a unique temp folder for this operation
	var temp_dir: String = "user://temp_import".path_join(str(Time.get_ticks_msec()) + "_" + file_path.get_file().get_basename())
	DirAccess.make_dir_recursive_absolute(temp_dir)

	var files: PackedStringArray = reader.get_files()
	for entry_path in files:
		var full_dest_path: String = temp_dir.path_join(entry_path)

		if entry_path.ends_with("/"):
			DirAccess.make_dir_recursive_absolute(full_dest_path)
		else:
			# Ensure parent directory exists
			var base_dir: String = full_dest_path.get_base_dir()
			if not DirAccess.dir_exists_absolute(base_dir):
				DirAccess.make_dir_recursive_absolute(base_dir)

			var content: PackedByteArray = reader.read_file(entry_path)
			var file: FileAccess = FileAccess.open(full_dest_path, FileAccess.WRITE)
			if file:
				file.store_buffer(content)
				file.close()

	reader.close()
	return temp_dir


func _find_manifest_in_path(search_dir: String) -> String:
	# Check root directory
	var root_manifest: String = search_dir.path_join("manifest.json")
	if FileAccess.file_exists(root_manifest):
		return root_manifest

	# If not, go down a level
	var dir: DirAccess = DirAccess.open(search_dir)
	if dir:
		dir.list_dir_begin()
		var dirname: String = dir.get_next()
		while dirname != "":
			if dir.current_is_dir() and not dirname.begins_with("."):
				var sub_manifest: String = search_dir.path_join(dirname).path_join("manifest.json")
				if FileAccess.file_exists(sub_manifest):
					return sub_manifest
			dirname = dir.get_next()
	return ""


func _parse_and_distribute(manifest_path: String, temp_root: String, zip_basename: String) -> void:
	var content: String = FileAccess.get_file_as_string(manifest_path)
	var json: JSON = JSON.new()
	if json.parse(content) != OK:
		print("PackImporter: JSON parse error for ", manifest_path)
		return

	var data = json.data
	if not (data is Dictionary) or not data.has("modules"):
		print("PackImporter: Invalid manifest structure")
		return

	var pack_id := ""
	if data.header.has("uuid"):
		pack_id = str(data.header.uuid)
	else:
		print("PackImporter: Manifest has no UUID")
		return

	# Check for existing packs
	if _uuid_exists(pack_id):
		print("PackImporter: Duplicate UUID found:", pack_id, "Skipping import.")
		AlertManager.show_alert("Duplicate pack(s) detected. Skipping.", Color.YELLOW)
		return

	var modules = data.modules
	if not (modules is Array):
		return

	var pack_type: String = ""
	# Check module type
	for mod in modules:
		if mod is Dictionary and mod.has("type"):
			pack_type = mod.type
			break

	var target_root: String = ""
	if pack_type == "resources":
		target_root = Global.WorldResourcePackPath
	elif pack_type == "data" or pack_type == "script":
		target_root = Global.WorldBehaviorPackPath
	else:
		print("PackImporter: Ignored unknown pack type: ", pack_type)
		return

	# Determine the folder name to copy
	# If the manifest was in a subfolder of the zip, copy that subfolder.
	# If the manifest was at the root of the zip, create a folder named after the zip.
	var source_pack_folder: String = manifest_path.get_base_dir()
	var pack_folder_name: String = source_pack_folder.get_file()

	# Check if source_pack_folder is effectively the temp root
	if source_pack_folder.replace("\\", "/") == temp_root.replace("\\", "/"):
		pack_folder_name = zip_basename

	var final_destination: String = target_root.path_join(pack_folder_name)

	_copy_recursive(source_pack_folder, final_destination)
	print("PackImporter: Imported ", pack_folder_name, " to ", final_destination)


func _uuid_exists(pack_id: String) -> bool:
	for pack in Global.RPList:
		if pack.pack_id == pack_id:
			return true

	for pack in Global.BPList:
		if pack.pack_id == pack_id:
			return true

	return false


func _copy_recursive(from: String, to: String) -> void:
	if not DirAccess.dir_exists_absolute(to):
		DirAccess.make_dir_recursive_absolute(to)

	var dir: DirAccess = DirAccess.open(from)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if not file_name.begins_with("."):
				var src_path: String = from.path_join(file_name)
				var dst_path: String = to.path_join(file_name)

				if dir.current_is_dir():
					_copy_recursive(src_path, dst_path)
				else:
					DirAccess.copy_absolute(src_path, dst_path)
			file_name = dir.get_next()


func _cleanup_temp(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		return

	var dir := DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not file_name.begins_with("."):
				var full_path := path.path_join(file_name)
				if DirAccess.dir_exists_absolute(full_path):
					_cleanup_temp(full_path) # recurse into subdir
					print("delete dir:", full_path)
				else:
					DirAccess.remove_absolute(full_path) # remove file
					print("delete file:", full_path)
			file_name = dir.get_next()
		dir.list_dir_end()
		DirAccess.remove_absolute(path) # finally remove the directory itself
		print("removed folder:", path)
