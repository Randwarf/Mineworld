extends Node2D

var rowCount = 150
var collumnCount = 150
var bombCount = 2500
var grid = []
var Tile = preload("res://Tile.tscn")
var Player = preload("res://Player.tscn")
var PlayerR = rowCount/2
var PlayerC = collumnCount/2

# Called when the node enters the scene tree for the first time.
func _init():
	var timeStart = OS.get_unix_time()
	print("creating NOTHING")
	OS.delay_msec(2000)
	print("Done creating NOTHING", OS.get_unix_time()-timeStart)
	
func _ready():
	var timeStart = OS.get_unix_time()
	print("creating grid")
	createGrid()
	print("Done creating grid", OS.get_unix_time()-timeStart)
	timeStart = OS.get_unix_time()
	print("setting bombs")
	setBombs()
	print("Done setting bombs", OS.get_unix_time()-timeStart)
	timeStart = OS.get_unix_time()
	print("clearing bombs")
	for r in range(PlayerR-2, PlayerR+3):
		for c in range(PlayerC-2, PlayerC+3):
			grid[r][c].isMine = false
	print("Done clearing bombs", OS.get_unix_time()-timeStart)
	timeStart = OS.get_unix_time()
	print("counting prox")
	countProximities()
	print("Done counting prox", OS.get_unix_time()-timeStart)
	timeStart = OS.get_unix_time()
	print("spawn player")
	spawnPlayer()
	print("Done spawning player", OS.get_unix_time()-timeStart)
	timeStart = OS.get_unix_time()
	print("initial uncover")
	uncover(PlayerR, PlayerC)
	print("Done uncovering", OS.get_unix_time()-timeStart)
	timeStart = OS.get_unix_time()
	

func spawnPlayer():
	Player = preload("res://Player.tscn")
	Player = Player.instance()
	Player.position = Vector2(PlayerR, PlayerC) * 16
	Player.grid = self
	add_child(Player)
	

func createGrid():
	for r in rowCount:
		grid.append([])
		for c in collumnCount:
			var tile = Tile.instance()
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
			grid[r][c].get_node("Proximity").text = str(proxCount)
			if proxCount == 0:
				grid[r][c].get_node("Proximity").text = ""

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
	var r = Player.position.y/16
	var c = Player.position.x/16
	grid[r][c].uncover()
	
func isMine(r, c):
	return grid[r][c].isMine
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
