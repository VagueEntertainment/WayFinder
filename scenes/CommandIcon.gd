extends TextureRect

signal pressed
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CommandIcon_gui_input(event):
	if event.is_pressed() and event.get_button_index() == 1:
		emit_signal("pressed")
