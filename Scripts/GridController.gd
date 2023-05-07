extends Node2D

var Player = preload("res://Player.tscn")
var Boss = preload("res://Boss_WOF.tscn")
var Goal = preload("res://Goal.tscn")
var healthLabel
var BiomeValues
var mapStartingSize = 3
var mapScalingIndex = 6
var mapSmoothingIndex = 3
var size #change this to instead use iteration size maybe
var rng = RandomNumberGenerator.new()
var mapInstance
var camera

var enableSniper = false

# Called when the node enters the scene tree for the first time.	
func _ready():
	healthLabel = get_node("PlayerCamera/Health/Label")
	healthLabel.text ="Initializing"
	
func generate(Biomes, boss):
	size = mapStartingSize
	for i in mapScalingIndex:
		size = (2*size)-1
	size = size - (mapSmoothingIndex*2)
	print(size)
	spawnPlayer()
	setupMap(size, size, 0.15, Biomes)	
	print(boss)
	spawnBoss(boss)
	setupCamera()
	#Player.initialized = true

func setupCamera():
	camera = get_node("PlayerCamera")
	camera.position = Player.position

func setupMap(rC, cC, bP, Biomes):
	BiomeValues = Biomes
	mapInstance = Map.new()
	mapInstance.Scene = self
	mapInstance.biomeDatas = Biomes
	add_child(mapInstance)

func spawnBoss(boss):
	if boss == "WOF":
		spawnWOF()
	elif boss == "FROG":
		spawnFROG()
	elif boss == "SNIPER":
		#spawnSNIPER()
		enableSniper = true

func spawnWOF():
	Boss = Boss.instantiate()
	add_child(Boss)
	Boss.position = Vector2(0,0)
	Boss.setTarget(Player)
	var r = mapInstance.rowCount/2
	var c = mapInstance.collumnCount-3
	Goal = Goal.instantiate()
	add_child(Goal)
	Goal.position = Vector2(c, r) *16
	mapInstance.clearArea(r,c,2)
	
func spawnFROG():
	Boss = preload("res://Boss_FROG.tscn")
	Boss = Boss.instantiate()
	add_child(Boss)
	Boss.position = Vector2(0,0)
	Boss.setTarget(Player)
	
func spawnSNIPER():
	Boss = preload("res://boss_SNIPER.tscn")
	Boss = Boss.instantiate()
	add_child(Boss)
	var cord = getPlayerPos()
	var spawnRadius = 4
	var minDist = 2
	var dist = 0
	var randR
	var randC
	while dist < minDist: #I literally just reroll over and over again, which may not be great here
		randR = randi_range(cord.r - spawnRadius, cord.r + spawnRadius + 1)
		randC = randi_range(cord.c - spawnRadius, cord.c + spawnRadius + 1)
		if inStorm(randR, randC):
			dist = calcPythagoras(cord.r, randR, cord.c, randC)
		minDist = minDist * 0.95
	Boss.position.y = randR * 16
	Boss.position.x = randC * 16
	Boss.setTarget(Player)
	
func calcPythagoras(r1, r2, c1, c2):
	return sqrt(pow(abs(r1-r2),2) + pow(abs(c1-c2),2))
	
func inStorm(Rpos, Cpos):
	print(Rpos, ' ', Cpos)
	print(BiomeValues[mapInstance.map[Rpos][Cpos][1]].biomeName)
	return BiomeValues[mapInstance.map[Rpos][Cpos][1]].storm

func spawnPlayer():
	Player = preload("res://Player.tscn")
	Player = Player.instantiate()
	Player.position = Vector2(size/2, size/2) * 16
	Player.grid = self
	add_child(Player)
	updateHealth()
	
func updateHealth():
	healthLabel.text = "{0}/{1}".format({"0":Player.lives, "1":Player.maxlives})

func updateBoard():
	mapInstance.updateBoard()
	
func isOnMine():
	var pos = getPlayerPos()
	return mapInstance.isMine(pos.r, pos.c)
	
func clearMapArea():
	var pos = getPlayerPos()
	var radius = 3
	mapInstance.clearGridMapArea(pos.r, pos.c, radius)
	mapInstance.updateImmediateBoard(radius)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	camera.position = camera.position.lerp(Player.truePos, delta*Player.movementSpeed*0.5)

func isWin():
	var r = mapInstance.rowCount/2
	var c = mapInstance.collumnCount-3
	if (Player.truePos.y/16 == r and Player.truePos.x/16 == c):
		return true
	return false

func getPlayerPos():
	return Coordinates.new(Player.truePos.y/16, Player.truePos.x/16)
