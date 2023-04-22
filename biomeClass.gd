class_name biomeClass extends Node2D

var biomeName
var mineChance
var color
var wallChance

func _init(n, mc, c, w=0):
	name = n
	mineChance = mc
	color = c
	wallChance = w
