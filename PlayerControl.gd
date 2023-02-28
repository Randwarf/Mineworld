extends Node2D


var grid
var goalPosition
# Called when the node enters the scene tree for the first time.
func _ready():
	var animatedSprite = get_node("AnimatedSprite")
	animatedSprite.animation = "idle"
	animatedSprite.playing = true
	
func _input(event):
	if event.is_action_pressed("ui_up"):
		position += Vector2(0, -16)
	elif event.is_action_pressed("ui_down"):
		position += Vector2(0, 16)
	elif event.is_action_pressed("ui_left"):
		position += Vector2(-16, 0)
	elif event.is_action_pressed("ui_right"):
		position += Vector2(16, 0)
	grid.updateBoard()
	if grid.isMine(position.y/16, position.x/16) == true:
		var gameOver = get_node("GameOver")
		gameOver.visible = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
