extends Node

const SETTINGS_FILE: String = "user://settings.conf"

var settings: Dictionary = {
	"HIDE_DEFAULT_SERVER_PACKS": true,
	"HIDE_TEXT_MODIFIER_SYMBOLS": true,
	"IMPORT_AS_UNIQUE_FOLDER_NAME": true,
	"USE_SYSTEM_TRASH_ON_DELETE": true,
	"RECENT_WORLD_LIST_SIZE": 5,
}


func _ready():
	print("[INFO] Program data directory: " + ProjectSettings.globalize_path("user://"))
	load_or_create_settings()


func load_or_create_settings():
	var file: FileAccess = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	if file:
		print("[INFO] Settings file found, loading...")
		while not file.eof_reached():
			var line: String = file.get_line().strip_edges()
			if line == "" or line.begins_with("#"):
				continue
			var parts: PackedStringArray = line.split("=")
			if parts.size() == 2:
				var key: String = parts[0].strip_edges()
				var value: String = parts[1].strip_edges()
				if settings.has(key): # only accept known keys
					settings[key] = parse_value(value)
					print("[INFO] Setting " + key + " is " + value)
		file.close()

		setting_integrity_checker()
		save_settings()
	else:
		print("[INFO] No settings file found, creating defaults...")
		save_settings()


func save_settings():
	var file: FileAccess = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	for key in settings.keys():
		file.store_line("%s=%s" % [key, settings[key]])
	file.close()


func parse_value(value: String) -> Variant:
	match value.to_lower():
		"true":
			return true
		"false":
			return false
		_:
			if value.is_valid_int():
				return int(value)
			elif value.is_valid_float():
				return float(value)
			else:
				return value


func get_setting(key: String) -> Variant:
	return settings.get(key, null)


func set_setting(key: String, value: Variant):
	if settings.has(key): # only allow known keys
		settings[key] = value
		print("[INFO] Setting '" + key + "' changed to: " + str(value))
		save_settings()


func setting_integrity_checker() -> void:
	# Recent world list size check
	var value = settings["RECENT_WORLD_LIST_SIZE"]
	if value is not int or value < 0 or value > 999:
		set_setting("RECENT_WORLD_LIST_SIZE", 5)


# Code to get setting value
# if LoadSettings.get_setting("SETTING_NAME"):
# Code to set setting value
# LoadSettings.set_setting("SETTING_NAME", true)
