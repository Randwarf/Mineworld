extends Node2D

var secWait = 0
var strength = 0
var target
var frozenX = 0
var frozenY = 0
var closeFreeze = false
var duration = 10
var trackingPercentage = 0.95 #percent for how long in the duration it is tracking the player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setTarget(toTarget):
	target = toTarget

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	secWait = secWait + delta
	if secWait > duration*trackingPercentage and closeFreeze == false:
		frozenX = target.position.x
		frozenY = target.position.y
		closeFreeze = true
	if secWait > duration:
		secWait = 0
		
		#firing code here
		
		closeFreeze = false
	strength = pow(2, 2*(secWait-duration))
	queue_redraw()

func _draw():
	if strength > 0.02:
		if secWait > duration*trackingPercentage:
			draw_line(Vector2(8, 8), Vector2(frozenX - position.x + 8, frozenY - position.y + 8), Color(255, 0, 0), 1)
		else:
			draw_line(Vector2(8, 8), Vector2(target.position.x - position.x + 8, target.position.y - position.y + 8), Color(255, 0, 0), strength)