extends Node

var alert_box: Control


func register_alert_box(node: Control) -> void:
	alert_box = node


func show_alert(message: String, color: Color) -> void:
	if alert_box:
		alert_box.show_alert(message, color)
		print("[MESSAGE] " + message)
