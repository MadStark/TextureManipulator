class_name NodeEditor
extends Control


var texture_node_scene = load("res://Scenes/Nodes/texture_node.tscn")
var float_node_scene = load("res://Scenes/Nodes/float_node.tscn")
var invert_node_scene = load("res://Scenes/Nodes/invert_node.tscn")
var grayscale_node_scene = load("res://Scenes/Nodes/grayscale_node.tscn")

@onready var application = get_node("/root/Application")

@onready var graph = $Layout/Editor/GraphEdit
@onready var output_node = $Layout/Editor/GraphEdit/OutputNode
@onready var output_preview = $Layout/Editor/ExportPanel/TextureRect
@onready var size_dropdown = $Layout/Editor/ExportPanel/OptionButton

var output_image:Image
var preview_texture:ImageTexture
var threads:Array
var waiter_thread:Thread
var colors_array = PackedByteArray()


func _ready():
	size_dropdown.select(4)
	for i in 16:
		threads.append(Thread.new())
	waiter_thread = Thread.new()
	output_image = Image.create(4, 4, false, Image.FORMAT_RGBA8)
	output_image.fill(Color.BLACK)
	preview_texture = ImageTexture.create_from_image(output_image)
	output_preview.texture = preview_texture


func _exit_tree():
	for i in threads.size():
		if threads[i].is_started():
			threads[i].wait_to_finish()


func add_node(scene):
	var instance = scene.instantiate()
	graph.add_child(instance)
	var spawn_position = graph.get_scroll_offset()
	spawn_position += graph.get_size() / 2
	instance.set_position_offset(spawn_position)


func calculate_final_image(width:int, height:int):
	_ensure_complete_image_thread_finished()
	output_image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	colors_array.resize(width * height * 4)
	var pixels_per_thread = int(int(width * height) / threads.size())
	for i in threads.size():
		threads[i].start(_process_image_chunk_threaded.bind(i * pixels_per_thread, pixels_per_thread, width, height))


func _finish_image_from_data():
	for i in threads.size():
		if threads[i].is_started():
			threads[i].wait_to_finish()
	output_image.set_data(output_image.get_width(), output_image.get_height(), false, Image.FORMAT_RGBA8, colors_array)
	preview_texture.call_deferred("set_image", output_image)
	#var preview = ImageTexture.create_from_image(output_image)
	#output_preview.texture = preview


func _process_image_chunk_threaded(start:int, count:int, width:int, height:int):
	for i in range(start, start + count):
		var x = int(i % width)
		var y = int(i / width)
		var p = int(i * 4)
		var uv = Vector2(float(x)/width, float(y)/height)
		var col = output_node.get_colour_output(uv)
		colors_array.set(p+0, col.r8)
		colors_array.set(p+1, col.g8)
		colors_array.set(p+2, col.b8)
		colors_array.set(p+3, col.a8)


func refresh_preview():
	calculate_final_image(128, 128)
	_ensure_complete_image_thread_finished()
	waiter_thread.start(_finish_image_from_data)

func _ensure_complete_image_thread_finished():
	if waiter_thread.is_started():
		waiter_thread.wait_to_finish()


func _on_export_pressed():
	var image_size = int(size_dropdown.get_item_text(size_dropdown.get_selected_id()))
	calculate_final_image(image_size, image_size)
	_finish_image_from_data()
	application.file_dialog_on_file_selected.connect(_on_file_selected_for_export)
	application.save_image()


func _on_update_preview_button_pressed():
	refresh_preview()


func _on_file_selected_for_export(path):
	application.file_dialog_on_file_selected.disconnect(_on_file_selected_for_export)
	if output_image == null:
		return
	output_image.save_png(path)
	

func _on_button_pressed():
	add_node(texture_node_scene)


func _on_new_float_button_pressed():
	add_node(float_node_scene)


func _on_new_invert_button_pressed():
	add_node(invert_node_scene)


func _on_new_grayscale_button_pressed():
	add_node(grayscale_node_scene)




