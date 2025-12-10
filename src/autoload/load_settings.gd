extends Node

const SETTINGS_FILE: String = "user://settings.conf"

var settings: Dictionary = {
	"HIDE_DEFAULT_SERVER_PACKS": true,
	"HIDE_TEXT_MODIFIER_SYMBOLS": true,
	"SUPER_SECRET_SETTING": false,
}


func _ready():
	print("Local directory: " + OS.get_data_dir())
	load_or_create_settings()


func load_or_create_settings():
	var file: FileAccess = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	if file:
		print("Settings file found, loading...")
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
		file.close()
		# Merge defaults: add any missing keys
		for key in settings.keys():
			if settings[key] == null:
				settings[key] = settings[key] # ensure default is set
		save_settings() # rewrite file with merged defaults
	else:
		print("No settings file found, creating defaults...")
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
		save_settings()


# Code to get setting value
# if LoadSettings.get_setting("SETTING_NAME"):
# Code to set setting value
# LoadSettings.set_setting("SETTING_NAME", true)
