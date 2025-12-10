class_name JsonParser
extends Node

var DEBUG_JSON: bool = false

# Data Structure
class ManifestInfo:
	var pack_folder: String = ""            # folder name on disk
	var name: String = ""                   # pack name from manifest
	var description: String = ""            # pack description
	var pack_id: String = ""                # header.uuid
	var version: Array[int] = []            # [1,0,0]
	var min_engine_version: Array[int] = [] # [1,0,0]
	var pack_icon: Texture2D = null         # optional icon
	var type: String = ""                   # resources | behavior | script
	var subpacks: Array = []                # array of dictionaries
	var dependencies: Array[String] = []    # pack uuid dependencies
	var active_subpack: String = ""         # chosen subpack folder_name
	var is_active: bool = false             # whether the pack is active in the world

# Lists
var ActiveRPJsonList: Array[Variant] = []
var ActiveBPJsonList: Array[Variant] = []
# All packs on disk
var RPList: Array[ManifestInfo] = []
var BPList: Array[ManifestInfo] = []
# Active packs only
var ActiveRPList: Array[ManifestInfo] = []
var ActiveBPList: Array[ManifestInfo] = []
# Inactive packs only
var InactiveRPList: Array[ManifestInfo] = []
var InactiveBPList: Array[ManifestInfo] = []


# Entry point
func ReadData():
	GetActivePacksJson()
	ParsePackContents()
	CompareActiveInactive()
	StringCleaner()
	Global.RPList = RPList
	Global.BPList = BPList


# Active pack JSON loading
func GetActivePacksJson():
	var rp_path: String = Global.WorldPath.path_join("world_resource_packs.json")
	var bp_path: String = Global.WorldPath.path_join("world_behavior_packs.json")

	_load_active_json(rp_path, ActiveRPList)
	_load_active_json(bp_path, ActiveBPList)


#  Full manifest scanning
func ParsePackContents():
	_parse_manifest_directory(Global.WorldResourcePackPath, RPList, "resources")
	_parse_manifest_directory(Global.WorldBehaviorPackPath, BPList, "behavior")


# Active / inactive sorting
func CompareActiveInactive():
	_order_and_split(RPList, ActiveRPList, InactiveRPList)
	_order_and_split(BPList, ActiveBPList, InactiveBPList)


# String cleaner
func StringCleaner() -> void:
	if not LoadSettings.get_setting("HIDE_TEXT_MODIFIER_SYMBOLS"):
		return

	for info in RPList:
		info.name = _remove_section_sign_and_next_char(info.name)
		info.description = _remove_section_sign_and_next_char(info.description)

	for info in BPList:
		info.name = _remove_section_sign_and_next_char(info.name)
		info.description = _remove_section_sign_and_next_char(info.description)


func _load_active_json(path: String, target_list: Array) -> void:
	if not FileAccess.file_exists(path):
		print("[_load_active_json] file not found:", path)
		return

	var text := FileAccess.get_file_as_string(path)

	if text.is_empty():
		print("[_load_active_json] file empty:", path)
		return

	var parser := JSON.new()
	var err := parser.parse(text)
	if err != OK:
		print("[_load_active_json] JSON parse failed for:", path, " err=", err)
		return

	var data = parser.data
	if typeof(data) != TYPE_ARRAY:
		print("[_load_active_json] expected array at root in:", path)
		return

	for entry in data:
		if typeof(entry) != TYPE_DICTIONARY:
			print("  -> skipping non-dictionary entry")
			continue
		# Fix: Skip only if neither pack_id nor uuid is present
		if not (entry.has("pack_id") or entry.has("uuid")):
			print("  -> skipping entry without pack_id/uuid")
			continue

		var info := ManifestInfo.new()
		# Fix: Set pack_id from pack_id if present, else from uuid
		if entry.has("pack_id"):
			info.pack_id = str(entry.pack_id)
		elif entry.has("uuid"):
			info.pack_id = str(entry.uuid)

		if entry.has("version"):
			info.version = []
			for v in entry.version:
				info.version.append(int(v))

		if entry.has("subpack"):
			info.active_subpack = str(entry.subpack)

		target_list.append(info)

	if DEBUG_JSON:
		print("\n[ACTIVE JSON] Loaded: ", path)
		print(JSON.stringify(data, "\t"))


func _parse_manifest_directory(dir_path: String, target_list: Array, pack_type: String) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var folder := dir.get_next()

	while folder != "":
		if dir.current_is_dir() and not folder.begins_with("."):
			var manifest_path := dir_path.path_join(folder).path_join("manifest.json")

			if FileAccess.file_exists(manifest_path):
				var info := _load_full_manifest(manifest_path)
				if info != null:
					info.pack_folder = folder
					info.type = pack_type
					# Load pack_icon.png if it exists
					var icon_path := dir_path.path_join(folder).path_join("pack_icon.png")
					if FileAccess.file_exists(icon_path):
						var img := Image.new()
						if img.load(icon_path) == OK:
							var tex := ImageTexture.create_from_image(img)
							info.pack_icon = tex
					target_list.append(info)

					if DEBUG_JSON:
						print("[INFO BUILT] Folder: ", folder)
						print("  Name: ", info.name)
						print("  UUID: ", info.pack_id)
						print("  Version: ", info.version)
						print("  Type: ", info.type)
						print("  Subpacks: ", info.subpacks)
						print("  Dependencies: ", info.dependencies)

		folder = dir.get_next()
	dir.list_dir_end()


#  Manifest.json parser
func _load_full_manifest(path: String) -> ManifestInfo:
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		return null

	var parser := JSON.new()
	if parser.parse(text) != OK:
		return null

	var root = parser.data
	if typeof(root) != TYPE_DICTIONARY:
		return null

	if not root.has("header"):
		return null

	var h = root.header
	if not h.has("uuid"):
		return null # must have UUID
	if not h.has("version"):
		return null # must have version array

	var info := ManifestInfo.new()

	# Header
	info.name = h.get("name", "")
	info.description = h.get("description", "")
	info.pack_id = h.get("uuid", "")
	info.version = []
	for v in h.get("version", []):
		info.version.append(int(v))
	info.min_engine_version = []
	for v in h.get("min_engine_version", []):
		info.min_engine_version.append(int(v))

	# Dependencies
	if root.has("dependencies"):
		for dep in root.dependencies:
			if dep.has("uuid"):
				info.dependencies.append(str(dep.uuid))

	# Subpacks
	if root.has("subpacks"):
		info.subpacks = []
		for sp in root.subpacks:
			info.subpacks.append(
				{
					"folder_name": sp.get("folder_name", ""),
					"name": sp.get("name", ""),
					"memory_tier": int(sp.get("memory_tier", 0)),
				},
			)

	if DEBUG_JSON:
		print("\n[MANIFEST] ", path)
		print(JSON.stringify(root, "\t"))

	return info


func _order_and_split(all_list: Array, active_json_list: Array, inactive_list: Array):
	# Build map of pack_id → ManifestInfo
	var map := { }
	for item in all_list:
		map[item.pack_id] = item

	# Rebuild active list IN THE SAME ORDER AS JSON FILE
	var ordered_active := []
	for a in active_json_list:
		if map.has(a.pack_id):
			var full_info: ManifestInfo = map[a.pack_id]
			full_info.active_subpack = a.active_subpack
			full_info.is_active = true # Set active flag
			ordered_active.append(full_info)

		if DEBUG_JSON:
			print("\n[ACTIVE SORTED]")
			for act in ordered_active:
				print("  ", act.pack_id, "  (", act.active_subpack, ")")

	# Store the ordered result
	active_json_list.clear()
	for item in ordered_active:
		active_json_list.append(item)

	# Build inactive list (in any natural order)
	for item in all_list:
		if not map[item.pack_id] in ordered_active:
			# actually check by ID
			var found := false
			for act in ordered_active:
				if act.pack_id == item.pack_id:
					found = true
					break
			if not found:
				inactive_list.append(item)

	if DEBUG_JSON:
		print("\n[INACTIVE]")
		for item in inactive_list:
			print("  ", item.pack_id)


func _remove_section_sign_and_next_char(input: String) -> String:
	var regex := RegEx.new()
	regex.compile("§.")
	return regex.sub(input, "", true)
