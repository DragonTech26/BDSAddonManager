extends Button

var messages: Array[Variant] = [
	"Hello world!",
	"DragonNotFoundError!",
	"Roar!",
	"Quack!",
	"You discovered the secret!",
	"Made in Godot!",
	"This splash text is hardcoded!",
]


func _ready() -> void:
	if LoadSettings.get_setting("SUPER_SECRET_SETTING"):
		self.visible = true


func _on_pressed() -> void:
	var random_index: int = randi() % messages.size()
	var random_message = messages[random_index]
	AlertManager.show_alert(random_message, Color.DEEP_SKY_BLUE)
