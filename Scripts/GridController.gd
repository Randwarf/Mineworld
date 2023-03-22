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
var size = 129 #change this to instead use iteration size maybe
var globalLoadRange = 10
var globalKillBorderWidth = 2
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
	generate(size,size,0.15)	
	camera = get_node("PlayerCamera")
	camera.position = Player.position
	
func generate(rC, cC, bP):
	rowCount = rC
	collumnCount = cC
	bombPercentage = bP
	PlayerR = rowCount/2
	PlayerC = collumnCount/2
	
	createMapWithBombs()
	
	initialBiomeGeneration()
	
	clearStartingArea()
	initializeSurroundings(PlayerR, PlayerC)
	
	
	spawnPlayer()
	countLocalProximities(globalLoadRange)
	#countProximities()
	#createGrid()
	#setBombs()
	#spawnBoss()
	updateBoard()

# Creates a map of integers that hold basic data for tile information
# Will be expanded on when biomes are added
func createMapWithBombs():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for r in rowCount:
		map.append([])
		grid.append([])
		for c in collumnCount:
			if rng.randf_range(0, 1) < bombPercentage:
				map[r].append(1)
			else:
				map[r].append(0)
			grid[r].append(null)

# Creates tiles for the surrounding area of the player and destroys them outside it
# This should be changed to instead initialize only the new tiles for better performace
# It currently looks through all surrounding tiles
# Or a different method could be used
func initializeSurroundings(Rpos, Cpos):
	for r in range(Rpos - globalLoadRange - globalKillBorderWidth, Rpos + globalLoadRange + globalKillBorderWidth + 1):
		for c in range(Cpos - globalLoadRange - globalKillBorderWidth, Cpos + globalLoadRange + globalKillBorderWidth + 1):
			if (r >= 0 and r <= rowCount-1 and c >= 0 and c <= collumnCount-1):
				if grid[r][c] == null:
					#create the tile in this coordinate
					var tile = Tile.instantiate()
					tile.position = Vector2(c, r) * tile.get_node("TileUnopened").texture.get_width()
					tile.r = r
					tile.c = c
					tile.grid = self
					add_child(tile)
					grid[r][c] = tile
					if map[r][c] == 1:
						grid[r][c].isMine = true
						grid[r][c].updateColor(1)
							
#						if (r <= Rpos - globalLoadRange + 1 and r >= Rpos - globalLoadRange) or (r >= Rpos + globalLoadRange - 1 and r <= Rpos + globalLoadRange) or (c <= Cpos - globalLoadRange and c >= Cpos - globalLoadRange - 1) or (c >= Cpos + globalLoadRange and c <= Cpos + globalLoadRange + 1):
#							if findUnlockedZeroTiles(r, c) == true:
#								grid[r][c].uncover()
				else:
					if r < Rpos - globalLoadRange or r > Rpos + globalLoadRange or c < Cpos - globalLoadRange or c > Cpos + globalLoadRange:
#						var raycast = RayCast2D.new()
#						add_child(raycast)
#						raycast.global_position = Vector2(c*16, r*16)
#						raycast.cast_to = Vector2(0, -1000)
#						if raycast.is_colliding():
#							var object_instance = raycast.get_collider()
#							print("caught")
#						else:
#							print("missed")
						pass
						#find the tile in this coordinate and destroy it
						
					elif findUnlockedZeroTiles(r, c) == true: #very innefficient to check every single tile, however, I could not figure out how to just check the edge
						grid[r][c].uncover()
								
						

func findUnlockedZeroTiles(row, collumn):
	for r in range(row-1, row+2):
		for c in range(collumn-1, collumn+2):
			if (r >= 0 and r <= rowCount-1 and c >= 0 and c <= collumnCount-1):
				if grid[r][c] != null:
					#if countProximity(r,c) == 0 and grid[r][c].status == 1:
					if grid[r][c].status == 1:
						return true
			else:
				return false #This is kinda bad, defaults to not uncovering at the edge of the grid

func countLocalProximities(loadRange):
	var pr = Player.truePos.y/16
	var pc = Player.truePos.x/16

	for r in range(pr - loadRange + 2, pr + loadRange - 2 + 1):
		for c in range(pc - loadRange + 2, pc + loadRange - 2 + 1):
			if (r >= 0 and r <= rowCount-1 and c >= 0 and c <= collumnCount-1):
				var proxCount = countProximity(r,c)
				var label = grid[r][c].get_node("Proximity")
				label.text = str(proxCount)
				label.modulate = proxColors[proxCount]
				if proxCount == 0:
					label.text = ""
#			if (r >= 0 and r <= rowCount and c >= 0 and c <= collumnCount):
#				if findUnlockedZeroTiles(r, c) == true:
#					var proxCount = countProximity(r,c)
#					var label = grid[r][c].get_node("Proximity")
#					label.text = str(proxCount)
#					label.modulate = proxColors[proxCount]
#					if proxCount == 0:
#						label.text = ""
#				else:
#					#load hidden tiles
#					pass


#Onto biome generation
func initialBiomeGeneration():
	var n = 5
	#var initialMap = define2DArray(n, 0)
	var finalsize = size #redudant
	var initialMap = ApplyBiomeValues(n)
	var shadowMap = initialMap
	var iterations = floor(log(finalsize)/log(2) - 3)
	iterations = 5 #shhh
	
	print(initialMap)
	
	for k in iterations:
		initialMap = zoom(shadowMap, n)
		n = (2*n)-1
		shadowMap = initialMap
	
	for k in 5:
		initialMap = smooth(initialMap, n)
		n = n - 2
		shadowMap = initialMap
	
	print(n)
	# OVERWRITES MAP FOR TESTING PURPOSES, DELETE LATER
	for i in n:
		for j in n:
			map[i][j] = initialMap[i][j]
	#print(initialMap)
	
func define2DArray(size, value):
	var arr = []
	for i in size:
		arr.append([])
		for j in size:
			arr[i].append(value)
	return arr

func ApplyBiomeValues(size): #Currently very very simple, can be expanded upon a lot
	size = size + 1
	var bitmap = define2DArray(size, 0)
	for i in size:
		for j in size:
			if (randi_range(0, 2) < 1):
				bitmap[i][j] = 0 
			else:
				bitmap[i][j] = 1
	return bitmap

func zoom(input, n):
	var newN = (2 * n) - 1
	var output = define2DArray(newN, 0)
	for i in n:
		for j in n:
			output[i*2][j*2] = input[i][j]
			#output.set(i * 2, j * 2, input[i * n + j])
	for i in range(newN):
		if i % 2 == 0:
			for j in range(1, newN - 1, 2):
				output[i][j] = pickOneRand(output[i][j - 1], output[i][j], 0, 0, 2)
				#output.set(i, j, pickOneRand(output.get(i, j - 1), output.get(i, j + 1), 0, 0, 2))
		else:
			for j in range(0, newN, 2):
				output[i][j] = pickOneRand(output[i + 1][j], output[i - 1][j], 0, 0, 2)
				#output.set(i, j, pickOneRand(output.get(i + 1, j), output.get(i - 1, j), 0, 0, 2))
			for j in range(1, newN - 1, 2):
				if output[i][j - 1] != 0 and output[i][j + 1] != 0 and output[i - 1][j] != 0 and output[i + 1][j] == 0:
					output[i][j] = output[i - 1][j]
					#output.set(i + 1, j, output.get(i - 1, j))
				output[i][j] = pickOneRand(output[i][j - 1], output[i][j + 1], output[i + 1][j], output[i - 1][j], 4)
	return output

func smooth(input, n):
	var output = define2DArray(n-2, 0)
	for i in n-2:
		for j in n-2:
			output[i][j] = input[i + 1][j + 1]
	for i in n-1:
		for j in n-1:
			if input[i + 1][j] == input[i - 1][j] and input[i][j + 1] == input[i][j - 1]:
				output[i - 1][j - 1] = pickOneRand(input[i + 1][j], input[i][j + 1], 0, 0, 2)
			elif input[i + 1][j] == input[i - 1][j]:
				output[i - 1][j - 1] = input[i + 1][j]
			elif input[i][j + 1] == input[i][j - 1]:
				output[i - 1][j - 1] = input[i][j + 1]
	return output;

func pickOneRand(a, b, c, d, amount):
	var list = []
	list.append(a)
	list.append(b)
	list.append(c)
	list.append(d)
	return list[randi_range(0, amount-1)]
	pass






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
			map[r][c] = 0	#Now changes the map instead of the grid

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
				if(map[r][c] == 1): #Now uses the map for checking
					count += 1
					
	return count
	
#Reikia queue
func uncover(row, collumn, depth = 0):
	if depth > 100:
		return
	for r in range(row-1, row+2):
		for c in range(collumn-1, collumn+2):
			if(r >= 0 and r < rowCount and c >= 0 and c < collumnCount):
				grid[r][c].uncover(depth+1)
				
func updateBoard():
	var r = Player.truePos.y/16
	var c = Player.truePos.x/16
	grid[r][c].uncover()
	initializeSurroundings(r, c) #----------------------------------------------------------
	countLocalProximities(globalLoadRange)
	
func isMine(r, c):
	return grid[r][c].isMine
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	camera.position = camera.position.lerp(Player.truePos, delta*Player.movementSpeed*0.5)

func isWin():
	
	var r = rowCount/2
	var c = collumnCount-3
	if (Player.truePos.y/16 == r and Player.truePos.x/16 == c):
		return true
	return false
