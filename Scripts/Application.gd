extends Node

@onready var file_dialog:FileDialog = $FileDialog

signal file_dialog_on_file_selected(path:String)


func open_image():
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.show()


func save_image():
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.show()


func _on_file_dialog_file_selected(path):
	file_dialog_on_file_selected.emit(path)
