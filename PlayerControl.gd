extends Node2D

var movementSpeed = 15
var animatedSprite
var grid
var isDead = false
var isMoving = false
var truePos = Vector2(position.x, position.y)
# Called when the node enters the scene tree for the first time.
func _ready():
	animatedSprite = get_node("AnimatedSprite")
	animatedSprite.animation = "idle"
	animatedSprite.playing = true
	truePos = Vector2(position.x, position.y)
	
func _input(event):
	if isDead:
		return
	if isMoving:
		#queue up a move
		#return
		pass
	if event.is_action_pressed("ui_up"):
		truePos = Vector2(truePos.x, truePos.y-16)
		isMoving = true
		animatedSprite.animation = "walk_up"
	elif event.is_action_pressed("ui_down"):
		truePos = Vector2(truePos.x, truePos.y+16)		
		isMoving = true		
		animatedSprite.animation = "walk_down"
	elif event.is_action_pressed("ui_left"):
		truePos = Vector2(truePos.x-16, truePos.y)		
		isMoving = true
		animatedSprite.animation = "walk_left"
	elif event.is_action_pressed("ui_right"):
		truePos = Vector2(truePos.x+16, truePos.y)		
		isMoving = true
		animatedSprite.animation = "walk_right"		
	grid.updateBoard()
	if grid.isMine(truePos.y/16, truePos.x/16) == true:
		var gameOver = get_node("GameOver")
		gameOver.visible = true
		isDead = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = position.linear_interpolate(truePos, delta*movementSpeed)
	if (position-truePos).length() < 0.1:
		isMoving = false
		animatedSprite.animation = "idle"
	
