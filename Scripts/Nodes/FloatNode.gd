extends EditorNode

@onready var input_field = $InputField


func get_colour_output(_port:int, _uv:Vector2) -> float:
	return float(input_field.get_text())


func _on_input_field_text_submitted(_new_text):
	editor.refresh_preview()
