class_name EditorNode
extends GraphNode

@onready var graph:NodeGraph = get_parent()
@onready var editor:NodeEditor = get_node("/root/Application/Graph")


func get_connection_to_port(port:int) -> NodePort:
	return graph.get_node_connected_to(name, port)


func get_node_with_name(node_name:StringName) -> GraphNode:
	return graph.get_node_with_name(node_name)
