extends Node2D

var status = 0
# 0 closed
# 1 open
# 2 flagged
# TODO: enum?

func _on_Control_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed and status == 0:
			$TileOpened.visible = true
			$Proximity.visible = true
		elif event.button_index == BUTTON_RIGHT and event.pressed and status == 0:
			$TileFlag.visible = true
