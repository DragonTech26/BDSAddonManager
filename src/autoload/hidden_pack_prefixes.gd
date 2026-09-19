extends Node

const PREFIXES_FILE: String = "user://hidden_pack_prefixes.conf"

const BEHAVIOR_PACKS_SECTION: String = "BEHAVIOR PACKS"
const RESOURCE_PACKS_SECTION: String = "RESOURCE PACKS"
const UUID_SECTION: String = "UUID"

const FILE_MESSAGE: PackedStringArray = [
	"# Comment out lines to disable them; deleted lines will be regenerated.",
	"# Add custom prefixes in the appropriate section, one per line. Lines starting with # are ignored.",
	"# Add pack UUIDs under [UUID], one per line, to hide a specific pack. An inline comment is allowed.",
	"",
]

const DEFAULT_PREFIXES: Dictionary = {
	BEHAVIOR_PACKS_SECTION: [
		"resourcepack.",
		"@minecraft",
		"behaviorpack.",
		"experimental",
		"update",
		"gametest",
		"villager trade rebalancing",
		"server editor library",
		"locator bar",
		"drop",
		"spring drop",
		"summer drop",
		"fall drop",
		"winter drop",
		"vanilla voxel shapes",
	],
	RESOURCE_PACKS_SECTION: [
		"resourcepack.",
		"@minecraft",
		"experimental",
	],
	UUID_SECTION: [],
}

func _ready() -> void:
	load_or_create_prefixes_file()


func load_or_create_prefixes_file() -> void:
	var sections := _read_prefix_file()
	sections = _sync_default_prefixes(sections)
	_save_prefix_file(sections)


func get_hidden_behavior_pack_entries() -> Dictionary:
	return get_hidden_entries(BEHAVIOR_PACKS_SECTION)


func get_hidden_resource_pack_entries() -> Dictionary:
	return get_hidden_entries(RESOURCE_PACKS_SECTION)


func get_hidden_uuids() -> Array[String]:
	load_or_create_prefixes_file()
	return _read_uuids()


func get_hidden_entries(section_name: String) -> Dictionary:
	load_or_create_prefixes_file()
	return {
		"prefixes": _read_prefixes(section_name),
		"uuids": _read_uuids(),
	}


func should_hide_pack(entries: Dictionary, pack_name: String, pack_uuid: String) -> bool:
	if pack_uuid != "" and entries["uuids"].has(pack_uuid.strip_edges().to_lower()):
		return true

	var n := pack_name.strip_edges().to_lower()
	for prefix in entries["prefixes"]:
		if n.begins_with(prefix):
			return true

	return false


func _read_section_lines(section_name: String) -> Array[String]:
	var lines: Array[String] = []

	var file := FileAccess.open(PREFIXES_FILE, FileAccess.READ)
	if file == null:
		print("[WARN] Could not read hidden prefixes file: " + PREFIXES_FILE)
		return lines

	var current_section := ""
	while not file.eof_reached():
		var line := file.get_line().strip_edges()

		if line.is_empty() or _is_comment(line):
			continue

		if _is_section_header(line):
			current_section = _get_section_name_from_header(line)
			continue

		if current_section == section_name:
			lines.append(line)

	file.close()
	return lines


func _read_prefixes(section_name: String) -> Array[String]:
	var prefixes: Array[String] = []

	for line in _read_section_lines(section_name):
		prefixes.append(line.to_lower())

	return prefixes


func _read_uuids() -> Array[String]:
	var uuids: Array[String] = []

	for line in _read_section_lines(UUID_SECTION):
		# Remove UUID note
		var uuid := line.split("#", true, 1)[0].strip_edges().to_lower()
		if uuid != "":
			uuids.append(uuid)

	return uuids


func _read_prefix_file() -> Dictionary:
	var sections := _get_empty_sections()

	if not FileAccess.file_exists(PREFIXES_FILE):
		return sections

	var file := FileAccess.open(PREFIXES_FILE, FileAccess.READ)
	if file == null:
		print("[WARN] Could not read hidden prefixes file: " + PREFIXES_FILE)
		return sections

	var current_section := ""
	while not file.eof_reached():
		var raw_line := file.get_line()
		var line := raw_line.strip_edges()

		if line.is_empty():
			continue

		if _is_section_header(line):
			current_section = _get_section_name_from_header(line)
			continue

		if not sections.has(current_section):
			continue

		sections[current_section].append(raw_line)

	file.close()
	return sections


func _sync_default_prefixes(sections: Dictionary) -> Dictionary:
	for section_name in DEFAULT_PREFIXES.keys():
		if not sections.has(section_name):
			sections[section_name] = []

		var existing_lines: Array = sections[section_name]
		var synced_lines: Array[String] = []

		for default_prefix in DEFAULT_PREFIXES[section_name]:
			var existing_default_line := _find_existing_default_line(existing_lines, default_prefix)

			if existing_default_line != "":
				synced_lines.append(existing_default_line)
			else:
				synced_lines.append(default_prefix)

		for line in existing_lines:
			if _line_matches_any_default(line, DEFAULT_PREFIXES[section_name]):
				continue

			synced_lines.append(line)

		sections[section_name] = synced_lines

	return sections


func _save_prefix_file(sections: Dictionary) -> void:
	var file := FileAccess.open(PREFIXES_FILE, FileAccess.WRITE)
	if file == null:
		print("[WARN] Could not write hidden prefixes file: " + PREFIXES_FILE)
		return

	for message_line in FILE_MESSAGE:
		file.store_line(message_line)

	for section_name in DEFAULT_PREFIXES.keys():
		file.store_line("[%s]" % section_name)

		for line in sections[section_name]:
			file.store_line(str(line).strip_edges())

		file.store_line("")

	file.close()


func _get_empty_sections() -> Dictionary:
	var sections := { }

	for section_name in DEFAULT_PREFIXES.keys():
		sections[section_name] = []

	return sections


func _find_existing_default_line(lines: Array, default_prefix: String) -> String:
	for line in lines:
		var clean_line := _strip_comment_marker(str(line).strip_edges()).to_lower()

		if clean_line == default_prefix.to_lower():
			return str(line).strip_edges()

	return ""


func _line_matches_any_default(line: String, default_prefixes: Array) -> bool:
	var clean_line := _strip_comment_marker(line.strip_edges()).to_lower()

	for default_prefix in default_prefixes:
		if clean_line == str(default_prefix).to_lower():
			return true

	return false


func _is_comment(line: String) -> bool:
	return line.begins_with("#")


func _strip_comment_marker(line: String) -> String:
	var clean_line := line.strip_edges()

	if clean_line.begins_with("#"):
		clean_line = clean_line.substr(1).strip_edges()

	return clean_line


func _is_section_header(line: String) -> bool:
	return line.begins_with("[") and line.ends_with("]")


func _get_section_name_from_header(line: String) -> String:
	return line.trim_prefix("[").trim_suffix("]").strip_edges().to_upper()
