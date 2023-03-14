extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var active = true
var background

# Called when the node enters the scene tree for the first time.
func _ready():
	background = get_node("ColorRect")

func activate():
	active = true
	visible = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		background.modulate.a+=delta*100
