extends Node


func ping_bedrock_server(ip: String, port: int) -> void:
	if ip.is_empty() || port == 0:
		return

	var nethernet_ok := await _ping_nethernet_http(ip, port)
	if nethernet_ok:
		return

	print("[NETWORK] NetherNet capability check got no response, trying RakNet ping...")
	await _ping_raknet(ip, port)


# NetherNet - https://wiki.bedrock.dev/servers/nethernet
func _ping_nethernet_http(ip: String, port: int, timeout: float = 3.0) -> bool:
	var http := HTTPRequest.new()
	add_child(http)
	http.timeout = timeout

	var url := "http://%s:%d/v1/join" % [ip, port]
	print("[NETWORK] Checking NetherNet capability at ", url)

	var err := http.request(url, PackedStringArray(), HTTPClient.METHOD_GET)
	if err != OK:
		print("[NETWORK] Failed to start HTTP request: ", err)
		http.queue_free()
		return false

	var result: Array = await http.request_completed
	http.queue_free()

	var http_result: int = result[0]
	var response_code: int = result[1]

	if http_result == HTTPRequest.RESULT_TIMEOUT:
		print("[NETWORK] NetherNet capability check timed out for ", ip, ":", port)
		return false
	if http_result == HTTPRequest.RESULT_CANT_CONNECT or http_result == HTTPRequest.RESULT_CANT_RESOLVE:
		print("[NETWORK] Couldn't connect to ", url, " (nothing listening there, or wrong port/scheme).")
		return false
	if http_result != HTTPRequest.RESULT_SUCCESS:
		print("[NETWORK] NetherNet capability check failed (result=", http_result, ") for ", ip, ":", port)
		return false

	if response_code >= 200 and response_code < 300:
		print("[NETWORK] Success! Bedrock server is ALIVE (NetherNet, HTTP ", response_code, ").")
		Global.ServerPing = true
		return true

	print("[NETWORK] NetherNet capability check got HTTP ", response_code, " for ", ip, ":", port, " (not 2xx).")
	return false


# RakNet - https://wiki.bedrock.dev/servers/raknet
func _ping_raknet(ip: String, port: int, timeout: float = 3.0) -> bool:
	var udp := PacketPeerUDP.new()
	if udp.bind(0) != OK:
		print("[NETWORK] Failed to bind UDP socket. Aborting RakNet check.")
		return false
	udp.connect_to_host(ip, port)

	var packet := PackedByteArray()
	packet.append(0x01) # Packet ID: Unconnected Ping
	var time_ms := Time.get_ticks_msec()
	for i in range(8):
		packet.append((time_ms >> (56 - i * 8)) & 0xFF) # Client Timestamp
	var magic := [0x00, 0xff, 0xff, 0x00, 0xfe, 0xfe, 0xfe, 0xfe, 0xfd, 0xfd, 0xfd, 0xfd, 0x12, 0x34, 0x56, 0x78]
	packet.append_array(PackedByteArray(magic))
	for i in range(8):
		packet.append(0x00) # Client GUID

	print("[NETWORK] Sending RakNet Unconnected Ping to ", ip, ":", port)
	udp.put_packet(packet)

	var elapsed := 0.0
	while elapsed < timeout:
		if udp.get_available_packet_count() > 0:
			var reply := udp.get_packet()
			if reply.size() > 0 and reply[0] == 0x1C: # Check if it's an Unconnected Ping (ID: 0x1C)
				print("[NETWORK] Success! Bedrock server is ALIVE (RakNet).")
				Global.ServerPing = true
				if reply.size() > 35:
					var server_info_bytes := reply.slice(35)
					var server_info_string := server_info_bytes.get_string_from_utf8()
					print("[NETWORK] Server Data: ", server_info_string)
					Global.ServerPingData = server_info_string
				udp.close()
				return true
		await get_tree().create_timer(0.05).timeout
		elapsed += 0.05

	udp.close()
	return false
