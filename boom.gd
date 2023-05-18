extends Node2D

var time = 0
var timeSpan = 0.75
var sprite
var scaleLevel = 1.02
# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = get_node("Sprite2D")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if time < timeSpan/2.0:
		$Sprite2D.scale *= Vector2(scaleLevel, scaleLevel)
	elif time < timeSpan:
		$Sprite2D.scale /= Vector2(scaleLevel, scaleLevel)
	else:
		queue_free()
	time+=delta
