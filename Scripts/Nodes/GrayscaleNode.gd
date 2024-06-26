extends EditorNode


func get_colour_output(port:int, uv:Vector2) -> float:
	var connection = get_connection_to_port(0)
	if connection == null:
		return 0
	var other = graph.get_node_with_name(connection.node)
	var colour = other.get_colour_output(connection.port, uv)
	return 0.299 * colour.x + 0.587 * colour.y + 0.114 * colour.y
