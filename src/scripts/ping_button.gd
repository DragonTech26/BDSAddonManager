extends Button

func _on_pressed() -> void:
	CheckServerPing.ping_bedrock_server("127.0.0.1", 19132)
