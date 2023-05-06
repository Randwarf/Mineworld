class_name biomeClass extends Node2D

var biomeName
var mineChance
var color
var wallChance
var storm

func _init(n, mc, c, w=0, s=false):
	biomeName = n
	mineChance = mc
	color = c
	wallChance = w
	storm = s
