extends Node2D

func _on_Control_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			$TileOpened.visible = true
