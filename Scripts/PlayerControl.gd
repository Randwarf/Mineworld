extends Node2D

var movementSpeed = 15
var animatedSprite
var grid
var isDead = false
var isMoving = false
var truePos = Vector2(position.x, position.y)
var moveQueue
var currentDirection
# Called when the node enters the scene tree for the first time.
func _ready():
	animatedSprite = get_node("AnimatedSprite2D")
	animatedSprite.animation = "idle"
	animatedSprite.play()
	truePos = Vector2(position.x, position.y)
	
func _input(event): #fyi this triggers on every mouse movement, sooooooooo
	if event is InputEventKey == false:
		return
	
	if isDead:
		return
	if event.is_action_pressed("ui_up"):
		if (isMoving and currentDirection != "up") or !isMoving:
			moveQueue = "up"
	elif event.is_action_pressed("ui_down"):
		if (isMoving and currentDirection != "down") or !isMoving:	
			moveQueue = "down"		
	elif event.is_action_pressed("ui_left"):
		if (isMoving and currentDirection != "left") or !isMoving:	
			moveQueue = "left"
	elif event.is_action_pressed("ui_right"):
		if (isMoving and currentDirection != "right") or !isMoving:	
			moveQueue = "right"
	
	if grid.isOnMine() == true:
		die()
	if grid.isWin() == true:
		print("true")
		win()
		
	if isMoving:
		#grid.initializeSurroundings(truePos.y/16, truePos.x/16)
		grid.updateBoard()
		#queue up a move
		#return
		return

func win():
	print("Winner winner chicken dinner")

func die():
	var gameOver = get_node("GameOver")
	gameOver.activate()
	isDead = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = position.lerp(truePos, delta*movementSpeed)
	if (position-truePos).length() < 0.1:
		position = truePos
		isMoving = false
		animatedSprite.animation = "idle"
	
	if !isMoving and moveQueue != null and !isDead:
		if moveQueue == "up":
			truePos = Vector2(truePos.x, truePos.y-16)
			isMoving = true
			animatedSprite.animation = "walk_up"
			moveQueue = null
			currentDirection = "up"
		elif moveQueue == "down":
			truePos = Vector2(truePos.x, truePos.y+16)		
			isMoving = true		
			animatedSprite.animation = "walk_down"
			moveQueue = null	
			currentDirection = "down"
		elif moveQueue == "left":
			truePos = Vector2(truePos.x-16, truePos.y)		
			isMoving = true
			animatedSprite.animation = "walk_left"
			moveQueue = null
			currentDirection = "left"
		elif moveQueue == "right":
			truePos = Vector2(truePos.x+16, truePos.y)		
			isMoving = true
			animatedSprite.animation = "walk_right"
			moveQueue = null
			currentDirection = "right"
