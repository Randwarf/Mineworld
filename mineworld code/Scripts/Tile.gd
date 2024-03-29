extends Node2D

var locked = false
var isMine = false
var isWall = false
var status = 0
var r
var c
var grid
# 0 closed
# 1 open | actually no, this is only true when "$Proximity.text == """" meaning it's 1 when a tile has no neighbors
# 2 flagged
# TODO: enum?
func updateColor(biomeColor): #Code to change the color based on biome index, not finished
	$TileOpened.modulate = biomeColor
	$TileUnopened.modulate = biomeColor
	$TileMine.modulate = biomeColor
	$TileWall.modulate = biomeColor

func setWall():
	isMine = false
	isWall = true
	locked = true
	$TileOpened.visible = false
	$Proximity.visible = false
	$TileMine.visible = false
	$TileWall.visible = true

func uncover(depth = 0):
	$TileUnopened.visible = false
	
	if !locked:
		if isMine:
			$TileMine.visible = true
		else:
			$TileOpened.visible = true
			$Proximity.visible = true
			
		if !isMine:
			$TileMine.visible = false
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
