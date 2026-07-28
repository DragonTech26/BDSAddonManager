extends Node


func ping_bedrock_server(ip: String, port: int):
	if ip.is_empty() || port == 0:
		return

	var udp = PacketPeerUDP.new()

	if udp.bind(0) != OK:
		print("[NETWORK] Failed to bind UDP socket. Aborting network check.")
		Global.ServerPing = false
		return
	udp.connect_to_host(ip, port)

	# Construct a valid "Unconnected Ping" packet
	var packet = PackedByteArray()
	packet.append(0x01) # Packet ID: Unconnected Ping

	# Client Timestamp (8 bytes - Long)
	var time_ms = Time.get_ticks_msec()
	for i in range(8):
		packet.append((time_ms >> (56 - i * 8)) & 0xFF)

	# RakNet Magic Bytes
	var magic = [0x00, 0xff, 0xff, 0x00, 0xfe, 0xfe, 0xfe, 0xfe, 0xfd, 0xfd, 0xfd, 0xfd, 0x12, 0x34, 0x56, 0x78]
	packet.append_array(PackedByteArray(magic))

	# Client GUID
	for i in range(8):
		packet.append(0x00)

	print("[NETWORK] Sending UDP Ping to Bedrock server at ", ip, ":", port)
	udp.put_packet(packet)

	# Wait for a response (Timeout after 3 seconds)
	var timeout = 3.0
	while timeout > 0:
		if udp.get_available_packet_count() > 0:
			var reply = udp.get_packet()

			# Check if it's an Unconnected Ping (ID: 0x1C)
			if reply.size() > 0 and reply[0] == 0x1C:
				print("[NETWORK] Success! Bedrock server is ALIVE.")
				Global.ServerPing = true

				if reply.size() > 35:
					var server_info_bytes = reply.slice(35)
					var server_info_string = server_info_bytes.get_string_from_utf8()
					print("[NETWORK] Server Data: ", server_info_string)
					Global.ServerPing = true
					Global.ServerPingData = server_info_string

				udp.close()
				return

		await get_tree().create_timer(0.05).timeout
		timeout -= 0.05

	print("[NETWORK] Failed! Server timed out (Offline or Firewall blocking UDP).")
	udp.close()
	Global.ServerPing = false

# https://wiki.bedrock.dev/servers/raknet
