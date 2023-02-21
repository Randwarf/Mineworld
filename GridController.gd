extends Node2D

var rowCount = 15
var collumnCount = 15
var bombCount = 15
var grid = []
var Tile = preload("res://Tile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
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
	setBombs()
	countProximities()
	
func setBombs():
	var bombs = 0
	while bombs < bombCount:
		var r = randi()%rowCount
		var c = randi()%collumnCount
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
	
func uncover(row, collumn):
	for r in range(row-1, row+2):
		for c in range(collumn-1, collumn+2):
			if(r >= 0 and r < rowCount and c >= 0 and c < collumnCount):
				grid[r][c].uncover()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
