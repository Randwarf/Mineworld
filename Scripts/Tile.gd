extends Node2D

var isMine = false
var status = 0
var r
var c
var grid
# 0 closed
# 1 open | actually no, this is only true when "$Proximity.text == """" meaning it's 1 when a tile has no neighbors
# 2 flagged
# TODO: enum?
func uncover(depth = 0):
	$TileUnopened.visible = false
	if isMine:
		$TileMine.visible = true
	else:
		$TileOpened.visible = true
		$Proximity.visible = true
		
	if status == 0 and $Proximity.text == "":
		status = 1
		grid.uncover(r,c, depth)

func _on_Control_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and status == 0:
			uncover()
		
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and status == 0:
			status = 2
			$TileFlag.visible = true
