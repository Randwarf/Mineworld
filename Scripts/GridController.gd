extends Node2D

var rowCount
var collumnCount
var bombCount
var grid = []
var Tile = preload("res://Tile.tscn")
var Player = preload("res://Player.tscn")
var Boss = preload("res://Boss_WOF.tscn")
var Goal = preload("res://Goal.tscn")
var PlayerR
var PlayerC
var proxColors = 	{1: Color(0,116.0/255,1),
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

# Called when the node enters the scene tree for the first time.	
func _ready():
	generate(50,50,350)	
	camera = get_node("PlayerCamera")
	camera.position = Player.position
	
func generate(rC, cC, bC):
	rowCount = rC
	collumnCount = cC
	bombCount = bC
	PlayerR = rowCount/2
	PlayerC = collumnCount/2
	
	createGrid()
	setBombs()
	clearStartingArea()
	countProximities()
	spawnPlayer()
	spawnBoss()
	updateBoard()

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
	clearArea(r,c,1)
	
func clearArea(Rpos,Cpos, radius):
	for r in range(Rpos-radius, Rpos+radius+1):
		for c in range(Cpos-radius, Rpos+radius+1):
			grid[r][c].isMine = false	

func clearStartingArea():
	clearArea(PlayerR, PlayerC, 2)

func spawnPlayer():
	Player = preload("res://Player.tscn")
	Player = Player.instantiate()
	Player.position = Vector2(PlayerC, PlayerR) * 16
	Player.grid = self
	add_child(Player)
	

func createGrid():
	for r in rowCount:
		grid.append([])
		for c in collumnCount:
			var tile = Tile.instantiate()
			tile.position = Vector2(c, r) * tile.get_node("TileUnopened").texture.get_width()
			tile.r = r
			tile.c = c
			tile.grid = self
			add_child(tile)
			grid[r].append(tile)
			
func setBombs():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var bombs = 0
	while bombs < bombCount:
		var r = rng.randi()%rowCount
		var c = rng.randi()%collumnCount
		if !grid[r][c].isMine:
			grid[r][c].isMine = true
			bombs+=1

func countProximities():
	for r in rowCount:
		for c in collumnCount:
			var proxCount = countProximity(r,c)
			var label = grid[r][c].get_node("Proximity")
			label.text = str(proxCount)
			label.modulate = proxColors[proxCount]
			if proxCount == 0:
				label.text = ""

func countProximity(row, collumn):
	var count = 0
	for r in range(row-1, row+2):
		for c in range(collumn-1, collumn+2):
			if(r >= 0 and r < rowCount and c >= 0 and c < collumnCount):
				if(grid[r][c].isMine):
					count += 1
	return count
	
#Reikia queue
func uncover(row, collumn, depth = 0):
	if depth > 200:
		return
	for r in range(row-1, row+2):
		for c in range(collumn-1, collumn+2):
			if(r >= 0 and r < rowCount and c >= 0 and c < collumnCount):
				grid[r][c].uncover(depth+1)
				
func updateBoard():
	var r = Player.truePos.y/16
	var c = Player.truePos.x/16
	grid[r][c].uncover()
	
func isMine(r, c):
	return grid[r][c].isMine
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	camera.position = camera.position.lerp(Player.truePos, delta*Player.movementSpeed*0.5)

func isWin():
	var r = rowCount/2
	var c = collumnCount-3
	print(Player.truePos.y/16, " ", Player.truePos.x/16,";",r," ",c)
	if (Player.truePos.y/16 == r and Player.truePos.x/16 == c):
		return true
	return false
