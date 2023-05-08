extends Node2D

var currentBiome
var timeInBiome
var storedMove = false
var lives = 3
var maxlives = 3
var movementSpeed = 20
var animatedSprite
var grid
var isDead = false
var isMoving = false
var truePos = Vector2(position.x, position.y)
var moveQueue
var currentDirection
var calledBoss = false

var obscureColor = Color(0.5,0,0,1)
var colorLevel = 1
var scaleLevel = 10
var boom = preload("res://boom.tscn")
var boomInstance

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
	animatedSprite.animation = "idle"
	if grid.isOnMine() == true:
		lowerLives(true)
	if grid.isWin() == true:
		print("true")
		win()

func lowerLives(clearGrid):
	if lives <= 0:
		die()
	else:
		lives -= 1
		grid.updateHealth()
		if clearGrid:
			grid.clearMapArea()
			grid.updateBoard()
			boomInstance = boom.instantiate()
			add_child(boomInstance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if initialized == false:
#		return
	
	stormProcessing(delta)
	
	if grid.mapInstance.grid[truePos.y/16][truePos.x/16].isWall:
		truePos = position
		
	position = position.lerp(truePos, delta*movementSpeed)
	storedMove = isMoving
	var dif = (position-truePos).length()
	if dif < 0.1 and isMoving == true:
		position = truePos
		isMoving = false
		moveCall()
	
	detectMovement()


func stormProcessing(delta):
	#enter a different biome
	if currentBiome != grid.mapInstance.map[truePos.y/16][truePos.x/16][1]:
		timeInBiome = 0
	timeInBiome = timeInBiome + delta
	currentBiome = grid.mapInstance.map[truePos.y/16][truePos.x/16][1]
	
	if grid.BiomeValues[currentBiome].storm: #designated biome index for the zone
		if $PlayerCamera/BigObscura.visible == false:
			$PlayerCamera/BigObscura.visible = true
		colorLevel = 1
		$PlayerCamera/BigObscura.modulate = grid.BiomeValues[currentBiome].color #shouldnt call every frame
		if scaleLevel > 0.5:
			scaleLevel = pow(1.1, -timeInBiome)*5
			$PlayerCamera/BigObscura.scale = Vector2(scaleLevel, scaleLevel)
		if scaleLevel < 1.75 and calledBoss == false:
			calledBoss = true
			grid.spawnSNIPER(3) #SNIPER FIRST SUMMON
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


func _on_player_col_area_entered(area):
	if area.name == "BulletCol":
		lowerLives(false)
