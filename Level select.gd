extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

			
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func generate(r,c,b):
	var grid = preload("res://GridScene.tscn")
	grid = grid.instance()
	grid.generate(r,c,b)
	add_child(grid)
	get_node("Control").visible=false
	get_node("Control2").visible=false
	get_node("Control3").visible=false
	

func _on_Control_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			generate(20,20,50)
			
func _on_Control2_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			generate(50,50,200)


func _on_Control3_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			generate(50,50,500)
