extends Node2D

var currentBiome
var timeInBiome
var storedMove = false
var lives = 3
var movementSpeed = 20
var animatedSprite
var grid
var isDead = false
var isMoving = false
var truePos = Vector2(position.x, position.y)
var moveQueue
var currentDirection

var obscureColor = Color(0.5,0,0,1)
var colorLevel
var scaleLevel = 10

#var initialized = false
# Called when the node enters the scene tree for the first time.
func _ready():
	animatedSprite = get_node("AnimatedSprite2D")
	animatedSprite.animation = "idle"
	animatedSprite.play()
	truePos = Vector2(position.x, position.y)
	timeInBiome = 0
	
func _input(event): #fyi this triggers on every mouse movement, sooooooooo
	if event is InputEventKey == false:
		return
	
	if isDead:
		return
	if event.is_action_pressed("ui_up"):
		moveQueue = "up"
	elif event.is_action_pressed("ui_down"):
		moveQueue = "down"		
	elif event.is_action_pressed("ui_left"):
		moveQueue = "left"
	elif event.is_action_pressed("ui_right"):
		moveQueue = "right"
		
#	if event.is_action_pressed("ui_up"):
#		if (isMoving and currentDirection != "up") or !isMoving:
#			moveQueue = "up"
#	elif event.is_action_pressed("ui_down"):
#		if (isMoving and currentDirection != "down") or !isMoving:	
#			moveQueue = "down"		
#	elif event.is_action_pressed("ui_left"):
#		if (isMoving and currentDirection != "left") or !isMoving:	
#			moveQueue = "left"
#	elif event.is_action_pressed("ui_right"):
#		if (isMoving and currentDirection != "right") or !isMoving:	
#			moveQueue = "right"
	
	
		
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
	
func moveCall(): #Is called once after a move is over
	position = truePos
	
	animatedSprite.animation = "idle"
	
	if grid.isOnMine() == true:
		if lives <= 0:
			die()
		else:
			print(lives)
			lives = lives - 1
			grid.clearMapArea()
			grid.updateBoard()
	
	if grid.isWin() == true:
		print("true")
		win()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if initialized == false:
#		return
	
	stormProcessing(delta)
	
	if grid.mapInstance.grid[truePos.y/16][truePos.x/16].isWall:
		truePos = position
		
	position = position.lerp(truePos, delta*movementSpeed)
	storedMove = isMoving
	if (position-truePos).length() < 0.1:
		isMoving = false
		if (isMoving != storedMove):
			moveCall()
	
	detectMovement()


func stormProcessing(delta):
	if currentBiome != grid.mapInstance.map[position.y/16][position.x/16][1]:
		timeInBiome = 0
	timeInBiome = timeInBiome + delta
	currentBiome = grid.mapInstance.map[position.y/16][position.x/16][1]
	
	if grid.BiomeValues[currentBiome].storm: #designated biome index for the zone
		if $PlayerCamera/BigObscura.visible == false:
			$PlayerCamera/BigObscura.visible = true
		colorLevel = 1
		$PlayerCamera/BigObscura.modulate = grid.BiomeValues[currentBiome].color
		if scaleLevel > 0.5:
			scaleLevel = pow(1.1, -timeInBiome)*10
			$PlayerCamera/BigObscura.scale = Vector2(scaleLevel, scaleLevel)
	else:
		if $PlayerCamera/BigObscura.visible == true:
			colorLevel = colorLevel - 0.05
			$PlayerCamera/BigObscura.modulate.a = colorLevel
			if colorLevel <= 0:
				$PlayerCamera/BigObscura.visible = false

func detectMovement():
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
