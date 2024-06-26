class_name NodeGraph
extends GraphEdit


@onready var editor:NodeEditor = $"../../.."
@onready var output_node:GraphNode = $OutputNode

var child_nodes_threadable = {}

var node_tree_reversed = {}


func get_node_with_name(node_name:StringName) -> GraphNode:
	return child_nodes_threadable[node_name]
	

func get_node_connected_to(node, port) -> NodePort:
	if node_tree_reversed.has(node) && node_tree_reversed[node].has(port):
		return node_tree_reversed[node][port]
	return null
	

func _refresh_node_tree_reversed():
	node_tree_reversed.clear()
	for connection in get_connection_list():
		var from_node:StringName = connection["from_node"]
		var from_port:int = connection["from_port"]
		var to_node:StringName = connection["to_node"]
		var to_port:int = connection["to_port"]

		if !node_tree_reversed.has(to_node):
			node_tree_reversed[to_node] = {}
			
		var node_port = NodePort.new()
		node_port.node = from_node
		node_port.port = from_port
		node_tree_reversed[to_node][to_port] = node_port


func _on_connection_request(from_node, from_port, to_node, to_port):
	var from_node_node = get_node_with_name(from_node)
	var to_node_node = get_node_with_name(to_node)
	
	var existing_connection_to_node = get_node_connected_to(to_node, to_port)
	if existing_connection_to_node != null:
		disconnect_node(existing_connection_to_node.node, existing_connection_to_node.port, to_node, to_port)

	var from_type = from_node_node.get_output_port_type(from_port)
	var to_type = to_node_node.get_input_port_type(to_port)
	if from_type == to_type:
		connect_node(from_node, from_port, to_node, to_port)
		_refresh_node_tree_reversed()
		editor.refresh_preview()


func _on_disconnection_request(from_node, from_port, to_node, to_port):
	disconnect_node(from_node, from_port, to_node, to_port)
	_refresh_node_tree_reversed()
	editor.refresh_preview()


func _on_child_entered_tree(node):
	child_nodes_threadable[node.name] = node


func _on_child_exiting_tree(node):
	child_nodes_threadable.erase(node.name)


func _on_delete_nodes_request(nodes:Array):
	var index_of_output_node:int = nodes.find(output_node.name)
	if index_of_output_node != -1:
		nodes.remove_at(index_of_output_node)
	for connection in get_connection_list():
		if nodes.has(connection.from_node) || nodes.has(connection.to_node):
			disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
	for node_name in nodes:
		get_node_with_name(node_name).free()
	_refresh_node_tree_reversed()
	editor.refresh_preview()
