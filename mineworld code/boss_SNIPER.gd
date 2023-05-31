extends Node2D

var bulletTscn = preload("res://bullet.tscn")
var grid
var secWait = 0
var strength = 0
var target
var frozenX = 0
var frozenY = 0
var closeFreeze = false
var duration = 10
var trackingPercentage = 0.95 #percent for how long in the duration it is tracking the player
var lives

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setTarget(toTarget, toGrid, toLives):
	lives = toLives
	grid = toGrid
	target = toTarget

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target.position == position:
		if (lives > 1):
			grid.spawnSNIPER(lives - 1)
		else:
			grid.Victory()
		queue_free()
	
	secWait = secWait + delta
	if secWait > duration*trackingPercentage and closeFreeze == false:
		frozenX = target.position.x
		frozenY = target.position.y
		var Bullet = bulletTscn.instantiate()
		add_child(Bullet)
		Bullet.setTarget(target)
		closeFreeze = true
	if secWait > duration:
		secWait = 0
		closeFreeze = false
	strength = pow(2, 2*(secWait-duration))
	queue_redraw()

func _draw():
	if strength > 0.02:
		if secWait > duration*trackingPercentage:
			draw_line(Vector2(8, 8), Vector2(frozenX - position.x + 8, frozenY - position.y + 8), Color(255, 0, 0), 1)
		else:
			draw_line(Vector2(8, 8), Vector2(target.position.x - position.x + 8, target.position.y - position.y + 8), Color(255, 0, 0), strength)
