extends EditorNode


func get_colour_output(uv : Vector2) -> Color:
	var r = get_node_value(uv, 0, 0.0);
	var g = get_node_value(uv, 1, 0.0);
	var b = get_node_value(uv, 2, 0.0);
	var a = get_node_value(uv, 3, 1.0);
	return Color(r, g, b, a)

func get_node_value(uv:Vector2, port:int, default:float) -> float:
	var connection = get_connection_to_port(port)
	if connection == null:
		return default
	var connected_node = graph.get_node_with_name(connection.node)
	return connected_node.get_colour_output(connection.port, uv)
