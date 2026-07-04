extends Button

@onready var server_ip: LineEdit = $"../IPLineEdit"
@onready var server_port: LineEdit = $"../PortLineEdit"

func _on_pressed() -> void:
	var target_ip: String = server_ip.text.strip_edges()
	var port_text: String = server_port.text.strip_edges()

	# Check for empty fields
	if target_ip.is_empty():
		AlertManager.show_alert("Please enter an IP address!", Color.YELLOW)
		return
	if port_text.is_empty():
		AlertManager.show_alert("Please enter a port!", Color.YELLOW)
		return

	# Port Validation
	if not port_text.is_valid_int():
		AlertManager.show_alert("Invalid Port: Must contain only numbers!", Color.RED)
		return

	var target_port = port_text.to_int()
	if target_port < 1 or target_port > 65535:
		AlertManager.show_alert("Invalid Port: Must be between 1 and 65535!", Color.RED)
		return

	# IP Validation
	if not target_ip.is_valid_ip_address():
		AlertManager.show_alert("Invalid format! Enter a valid IP (e.g. 127.0.0.1).", Color.RED)
		return

	CheckServerPing.ping_bedrock_server(target_ip, target_port)
