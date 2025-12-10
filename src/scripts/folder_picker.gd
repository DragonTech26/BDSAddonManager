extends FileDialog

var _target: LineEdit = null


func _ready():
	file_mode = FILE_MODE_OPEN_DIR
	access = ACCESS_FILESYSTEM
	connect("dir_selected", _on_dir_selected)
	connect("canceled", _on_canceled)


func open_for(target_lineedit: LineEdit):
	_target = target_lineedit
	current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	popup_centered()


func _on_dir_selected(path: String):
	if _target:
		_target.text = path
	_target = null


func _on_canceled():
	_target = null
