class_name Map extends Node2D
#---internal classes---
#---consts---
var biomeDatas = [ 
	
]
const proxColors = 	{
	1: Color(0,116.0/255,1),
	2: Color.DARK_GREEN,
	3: Color(1,0,0),
	4: Color(0,0,255.0/139),
	5: Color(126.0/255, 13/255.0, 45/255.0),
	6: Color(0,135/255.0,1),
	7: Color(0,0,0),
	8: Color(0.3,0.3,0.3),
	9: Color(1,1,1),
	0: Color(1,1,1)
}
const mapStartingSize = 3
const mapScalingIndex = 6
const mapSmoothingIndex = 3
const globalLoadRange = 15
const globalKillBorderWidth = 1

#---variables---
var size
var rowCount
var collumnCount
var bombCount
var map = [] #[][] grid of values with an array inside [isMine, biomeIndex]. Currently just the isMine part, so, no triple array
var grid = []
var Tile = preload("res://Tile.tscn")
var rng = RandomNumberGenerator.new()
var Scene



# Called when the node enters the scene tree for the first time.
func _ready():
	calculateOptimalSize()
	rowCount = size
	collumnCount = size
	grid = define2DArray(size, null)
	initialBiomeGeneration()
	createMapWithBombs()
	clearStartingArea()
	actuallyInitializeSurroundings()
	countLocalProximities()
	updateBoard()

func calculateOptimalSize():
	size = mapStartingSize
	for i in mapScalingIndex:
		size = (2*size)-1
	size = size - (mapSmoothingIndex*2)

func initializeBiomeData():
	var biomeData = []
	
# Creates a map of integers that hold basic data for tile information
# Will be expanded on when biomes are added
func createMapWithBombs(): #Walls included
	rng.randomize()
	for r in rowCount:
		for c in collumnCount:
			var biomeIndex = map[r][c][1]
			var biomeMineChance = biomeDatas[biomeIndex].mineChance
			var biomeWallChance = biomeDatas[biomeIndex].wallChance
			map[r][c][0] = addMine(biomeMineChance)
			map[r][c][2] = addMine(biomeWallChance)

func addMine(chance):
	if rng.randf_range(0, 1) < chance:
		return 1
	else:
		return 0

# Creates tiles for the surrounding area of the player and destroys them outside it
# This should be changed to instead initialize only the new tiles for better performace
# It currently looks through all surrounding tiles
# Or a different method could be used
func updateSurroundings(Rpos, Cpos):
	for r in range(Rpos - globalLoadRange - globalKillBorderWidth, Rpos + globalLoadRange + globalKillBorderWidth + 1):
		for c in range(Cpos - globalLoadRange - globalKillBorderWidth, Cpos + globalLoadRange + globalKillBorderWidth + 1):
			if (r >= 0 and r <= rowCount-1 and c >= 0 and c <= collumnCount-1):
				if r < Rpos - globalLoadRange or r > Rpos + globalLoadRange or c < Cpos - globalLoadRange or c > Cpos + globalLoadRange:
					if grid[r][c] == null:
						generateTile(r, c)
					else: # There is currently no deletion because IT SUCKS
						# This code does delete tiles, but it affects the wrong tiles as it seemingly randomly does not delete them and the code regenerates them
						#remove_child(grid[r][c])
						#grid[r][c] = null
						pass
				elif findUnlockedZeroTiles(r, c) == true: #very innefficient to check every single tile, however, I could not figure out how to just check the edge
					if grid[r][c] != null:
						grid[r][c].uncover()

#func updateImmediateSurroundings(Rpos, Cpos, radius):
#	for r in range(Rpos - globalLoadRange - globalKillBorderWidth, Rpos + globalLoadRange + globalKillBorderWidth + 1):
#		for c in range(Cpos - globalLoadRange - globalKillBorderWidth, Cpos + globalLoadRange + globalKillBorderWidth + 1):
#			if (r >= 0 and r <= rowCount-1 and c >= 0 and c <= collumnCount-1):
#				if map[r][c][0] == 1:
#					grid[r][c].isMine = true #ULTRA RARE BUG?
#				else:
#					grid[r][c].isMine = false

func actuallyInitializeSurroundings():
	var playerPos = Scene.getPlayerPos()
	var Rpos = playerPos.r
	var Cpos = playerPos.c
	for r in range(Rpos - globalLoadRange - globalKillBorderWidth, Rpos + globalLoadRange + globalKillBorderWidth + 1):
		for c in range(Cpos - globalLoadRange - globalKillBorderWidth, Cpos + globalLoadRange + globalKillBorderWidth + 1):
			if (r >= 0 and r <= rowCount-1 and c >= 0 and c <= collumnCount-1):
				generateTile(r, c)

func generateTile(r, c):
	var tile = Tile.instantiate()
	tile.position = Vector2(c, r) * tile.get_node("TileUnopened").texture.get_width()
	tile.r = r
	tile.c = c
	tile.grid = self
	add_child(tile)
	grid[r][c] = tile
	if map[r][c][0] == 1:
		grid[r][c].isMine = true
	if map[r][c][2] == 1:
		grid[r][c].setWall()
		map[r][c][0] = 0
	var color = biomeDatas[map[r][c][1]].color
	grid[r][c].updateColor(color)

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

func countLocalProximities():
	var playerPos = Scene.getPlayerPos()
	var pr = playerPos.r
	var pc = playerPos.c
	for r in range(pr - globalLoadRange, pr + globalLoadRange + 1):
		for c in range(pc - globalLoadRange, pc + globalLoadRange + 1):
			if (r >= 0 and r <= rowCount-1 and c >= 0 and c <= collumnCount-1):
				if grid[r][c] != null:
					var proxCount = countProximity(r,c)
					var label = grid[r][c].get_node("Proximity")
					label.text = str(proxCount)
					label.modulate = proxColors[proxCount]
					if proxCount == 0:
						label.text = ""
#				else:
#					#load hidden tiles
#					pass


#Onto biome generation
func initialBiomeGeneration():
	var n = mapStartingSize
	var finalsize = size #redudant
	var initialMap = ApplyBiomeValues(n)
	var shadowMap = initialMap
	var iterations = floor(log(finalsize)/log(2) - 3) #this should work
	iterations = mapScalingIndex #shhh
	
	for k in iterations:
		initialMap = zoom(shadowMap, n)
		#print2DArray(initialMap, n)
		n = (2*n)-1
		shadowMap = initialMap
	
	for k in mapSmoothingIndex:
		initialMap = smooth(initialMap, n)
		n = n - 2
		shadowMap = initialMap
	map = defineMapArray(size, 0, 0)
	# OVERWRITES MAP
	for i in n:
		for j in n:
			map[i][j][1] = initialMap[i][j]
	



func ApplyBiomeValues(size): #Currently very very simple, can be expanded upon a lot
	size = size + 1
	var bitmap = define2DArray(size, 0)
	for i in size:
		for j in size:
			var number = randi_range(0, biomeDatas.size()-1)
			bitmap[i][j] = number
			#if randi_range(0, biomeDatas.size()) < 1:
			#	bitmap[i][j] = 0 
			#elif randi_range(0, biomeDatas.size()) < 1:
			#	bitmap[i][j] = 1
			#else:
			#	bitmap[i][j] = 2
	return bitmap

func zoom(input, n):
	var newN = (2 * n) - 1
	var output = define2DArray(newN, 0)
	for i in n:
		for j in n:
			output[i*2][j*2] = input[i][j]
	for i in range(newN):
		if i % 2 == 0:
			for j in range(1, newN - 1, 2):
				output[i][j] = pickOneRand(output[i][j - 1], output[i][j + 1], 0, 0, 2)
		else:
			for j in range(0, newN, 2):
				output[i][j] = pickOneRand(output[i + 1][j], output[i - 1][j], 0, 0, 2)
			for j in range(1, newN - 1, 2):
				if output[i][j - 1] != 0 and output[i][j + 1] != 0 and output[i - 1][j] != 0 and output[i + 1][j] == 0:
					output[i + 1][j] = output[i - 1][j]
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
	var list = [a,b,c,d]
	return list[randi_range(0, amount-1)]
	
	

func print2DArray(arr, n): #Literally just for testing purposes
	print(n)
	for i in n:
		var output = ""
		for j in n:
			if (arr[i][j] == 1):
				output = str(output, "X ")
			else:
				output = str(output, "  ")
		print(output)
			
func define2DArray(size, value):
	var arr = []
	for i in size:
		arr.append([])
		for j in size:
			arr[i].append(value)
	return arr
	
func defineMapArray(size, value1, value2):
	var arr = []
	for i in size:
		arr.append([])
		for j in size:
			arr[i].append([])
			for k in 2:
				arr[i][j].append(value1)
				arr[i][j].append(value2)
	return arr
	
func uncover(row, collumn, depth = 0):
	if depth > 100:
		return
	for r in range(row-1, row+2):
		for c in range(collumn-1, collumn+2):
			if(r >= 0 and r < rowCount and c >= 0 and c < collumnCount):
				if grid[r][c] != null:
					grid[r][c].uncover(depth+1)
					
func countProximity(row, collumn):
	var count = 0
	for r in range(row-1, row+2):
		for c in range(collumn-1, collumn+2):
			if(r >= 0 and r < rowCount and c >= 0 and c < collumnCount):
				if(map[r][c][0] == 1): #Now uses the map for checking
					count += 1
	return count

func isMine(r, c):
	return grid[r][c].isMine
	
func clearArea(Rpos,Cpos, radius):
	for r in range(Rpos-radius, Rpos+radius+1):
		for c in range(Cpos-radius, Rpos+radius+1):
			map[r][c][0] = 0	#Now changes the map instead of the grid

#copy of the top function with grid clearing as well. Did this because the top function runs once before grid exists
func clearGridMapArea(Rpos,Cpos, radius): 
	for r in range(Rpos-radius, Rpos+radius+1):
		for c in range(Cpos-radius, Cpos+radius+1):
			map[r][c][0] = 0
			grid[r][c].isMine = false

func clearStartingArea():
	var pos = Scene.getPlayerPos()
	clearArea(pos.r, pos.c, 2)

func updateImmediateBoard(pos, radius):
	grid[pos.r][pos.c].uncover()
	#updateImmediateSurroundings(playerPos.r, playerPos.c, radius) #----------------------------------------------------------
	countLocalProximities()
	
func updateBoard():
	var playerPos = Scene.getPlayerPos()
	grid[playerPos.r][playerPos.c].uncover()
	updateSurroundings(playerPos.r, playerPos.c) #----------------------------------------------------------
	countLocalProximities()

func SetWalls(pos, radius):
	var Rpos=pos.r
	var Cpos=pos.c
	for r in range(Rpos-radius, Rpos+radius+1):
		for c in range(Cpos-radius, Cpos+radius+1):
			map[r][c][2] = true
			grid[r][c].setWall()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
