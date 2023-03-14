extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var target

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setTarget(toTarget):
	target = toTarget

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y = target.position.y
	var distance = target.position.x-position.x
	var speed = pow(distance/32, 2) + 5
	position.x += speed*delta
	
	if position.x > target.position.x:
		target.die()
