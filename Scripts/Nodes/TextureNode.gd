extends EditorNode

@onready var application = get_node("/root/Application")

@onready var preview = $Preview

var has_texture = false
var image
var texture


func _ready():
	promt_select_image()


func _on_button_pressed():
	promt_select_image()


func promt_select_image():
	application.file_dialog_on_file_selected.connect(_on_file_selected)
	application.open_image()


func _on_file_selected(path):
	application.file_dialog_on_file_selected.disconnect(_on_file_selected)
	print("Selected " + path)
	load_image(path)


func load_image(path):	
	image = Image.new()
	image.load(path)
	texture = ImageTexture.new()
	texture.set_image(image)
	has_texture = true
	editor.refresh_preview()
	preview.texture = texture


func get_colour_output(port:int, uv:Vector2):
	if !has_texture:
		return 0
	match port:
		0:
			return image.get_pixel(uv.x * image.get_width(), uv.y * image.get_height())
		1:
			var col = image.get_pixel(uv.x * image.get_width(), uv.y * image.get_height())
			var rgb = Vector3(col.r, col.g, col.b)
			return rgb
		2:
			return image.get_pixel(uv.x * image.get_width(), uv.y * image.get_height()).r
		3:
			return image.get_pixel(uv.x * image.get_width(), uv.y * image.get_height()).g
		4:
			return image.get_pixel(uv.x * image.get_width(), uv.y * image.get_height()).b
		5:
			return image.get_pixel(uv.x * image.get_width(), uv.y * image.get_height()).a
	return 0
