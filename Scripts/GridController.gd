extends Node2D

var Player = preload("res://Player.tscn")
var Boss = preload("res://Boss_WOF.tscn")
var Goal = preload("res://Goal.tscn")
var mapStartingSize = 3
var mapScalingIndex = 6
var mapSmoothingIndex = 3
var size #change this to instead use iteration size maybe
var rng = RandomNumberGenerator.new()
var mapInstance
var camera

# Called when the node enters the scene tree for the first time.	
func _ready():
	pass
	
func generate(Biomes):
	size = mapStartingSize
	for i in mapScalingIndex:
		size = (2*size)-1
	size = size - (mapSmoothingIndex*2)
	print(size)
	spawnPlayer()
	setupMap(size, size, 0.15, Biomes)	
	spawnBoss()
	setupCamera()
	Player.initialized = true

func setupCamera():
	camera = get_node("PlayerCamera")
	camera.position = Player.position

func setupMap(rC, cC, bP, Biomes):
	mapInstance = Map.new()
	mapInstance.Scene = self
	mapInstance.biomeDatas = Biomes
	add_child(mapInstance)

func spawnBoss():
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

func spawnPlayer():
	Player = preload("res://Player.tscn")
	Player = Player.instantiate()
	Player.position = Vector2(size/2, size/2) * 16
	Player.grid = self
	add_child(Player)

func updateBoard():
	mapInstance.updateBoard()
	
func isOnMine():
	var pos = getPlayerPos()
	return mapInstance.isMine(pos.r, pos.c)
	
func clearMapArea():
	var pos = getPlayerPos()
	var radius = 3
	mapInstance.clearArea(pos.r, pos.c, radius)
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
