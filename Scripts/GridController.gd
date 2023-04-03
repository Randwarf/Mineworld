extends Node2D

var rowCount
var collumnCount
var bombPercentage
var bombCount
var map = [] #[][] grid of values with an array inside [isMine, biomeIndex]. Currently just the isMine part, so, no triple array
var grid = []
var Tile = preload("res://Tile.tscn")
var Player = preload("res://Player.tscn")
var Boss = preload("res://Boss_WOF.tscn")
var Goal = preload("res://Goal.tscn")
var PlayerR
var PlayerC
var mapStartingSize = 3
var mapScalingIndex = 5
var mapSmoothingIndex = 3
var size #change this to instead use iteration size maybe
var globalLoadRange = 15
var globalKillBorderWidth = 1
var rng = RandomNumberGenerator.new()
var mapInstance

const proxColors = 	{1: Color(0,116.0/255,1),
2: Color.DARK_GREEN,
3: Color(1,0,0),
4: Color(0,0,255.0/139),
5: Color(126.0/255, 13/255.0, 45/255.0),
6: Color(0,135/255.0,1),
7: Color(0,0,0),
8: Color(0.3,0.3,0.3),
9: Color(1,1,1),
0: Color(1,1,1)}
var camera

# MAKE THIS INTO SOME SORT OF A CLASS WHICH YOU CAN REFERENCE
class biomeClass:
	var name
	var mineChance
	var color
	
#Should store all the data for a biome
#Currently that is mine spawnrate and coloring of the tiles
const biomeDatas = [ 
	[0.05, Color(0,0,0)],
	[0.2, Color(0.5,0,0)],
	[0.4, Color(0,0.5,0)]
]
var biomeCount #How many biomes are enabled, latter ones are excluded

func initializeBiomeData():
	var biomeData = []

# Called when the node enters the scene tree for the first time.	
func _ready():
	
	size = mapStartingSize
	for i in mapScalingIndex:
		size = (2*size)-1
	size = size - (mapSmoothingIndex*2)
	print(size)
	generate(size,size,0.15)
	setupMap(size, size, 0.15)		
	setupCamera()

func setupCamera():
	camera = get_node("PlayerCamera")
	camera.position = Player.position

func setupMap(rC, cC, bP):
	mapInstance = Map.new()
	mapInstance.Scene = self
	add_child(mapInstance)

func generate(rC, cC, bP):
	rowCount = rC
	collumnCount = cC
	bombPercentage = bP
	PlayerR = rowCount/2
	PlayerC = collumnCount/2
	
	spawnPlayer()
	#spawnBoss()

func spawnBoss():
	Boss = Boss.instantiate()
	add_child(Boss)
	Boss.position = Vector2(0,0)
	Boss.setTarget(Player)
	var r = rowCount/2
	var c = collumnCount-3
	Goal = Goal.instantiate()
	add_child(Goal)
	Goal.position = Vector2(c, r) *16
	mapInstance.clearArea(r,c,1)

func spawnPlayer():
	Player = preload("res://Player.tscn")
	Player = Player.instantiate()
	Player.position = Vector2(PlayerC, PlayerR) * 16
	Player.grid = self
	add_child(Player)

func updateBoard():
	mapInstance.updateBoard()
	
func isOnMine():
	var pos = getPlayerPos()
	return mapInstance.isMine(pos.r, pos.c)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	camera.position = camera.position.lerp(Player.truePos, delta*Player.movementSpeed*0.5)

func isWin():
	var r = rowCount/2
	var c = collumnCount-3
	if (Player.truePos.y/16 == r and Player.truePos.x/16 == c):
		return true
	return false

func getPlayerPos():
	return Coordinates.new(Player.truePos.y/16, Player.truePos.x/16)


#func setBombs():
#	var rng = RandomNumberGenerator.new()
#	rng.randomize()
#	var bombs = 0
#	while bombs < bombCount:
#		var r = rng.randi()%rowCount
#		var c = rng.randi()%collumnCount
#		if !grid[r][c].isMine:
#			grid[r][c].isMine = true
#			bombs+=1

#func countProximities():
#	for r in rowCount:
#		for c in collumnCount:
#			var proxCount = countProximity(r,c)
#			var label = grid[r][c].get_node("Proximity")
#			label.text = str(proxCount)
#			label.modulate = proxColors[proxCount]
#			if proxCount == 0:
#				label.text = ""

#func createGrid():
#	for r in rowCount:
#		grid.append([])
#		for c in collumnCount:
#			var tile = Tile.instantiate()
#			tile.position = Vector2(c, r) * tile.get_node("TileUnopened").texture.get_width()
#			tile.r = r
#			tile.c = c
#			tile.grid = self
#			add_child(tile)
#			grid[r].append(tile)
