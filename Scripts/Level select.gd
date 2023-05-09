extends Node2D

var grid = preload("res://GridScene.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var easyBiome = biomeClass.new("Easy",  0.05, Color(1,1,1))

var BiomeBackup = [ 
	biomeClass.new("Easy",  0.05, Color(1,1,1)),
	biomeClass.new("Easy2",  0.08, Color(1,0.8,1)),
	biomeClass.new("Medium",0.1,  Color(0.5,0,0)),
	biomeClass.new("Medium2",0.14,  Color(0.5,0.5,0)),
	biomeClass.new("Hard",  0.2, Color(0,0.5,0.9)),
	biomeClass.new("Hard2",  0.25, Color(0,0,0.5), 0, true),
	biomeClass.new("Hard3",  0.3, Color(0,0.8,0.8), 0.1)
]
			
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func generate(Biomes, boss):
	grid = grid.instantiate()
	
	
	add_child(grid)
	grid.generate(Biomes, boss)
	
	get_node("CenterContainer").visible=false

func _on_button_Q_pressed():
	get_tree().quit()

func _on_button_3_pressed():
	var Biomes = [ BiomeBackup[5]]
	print('button3')
	generate(Biomes, "SNIPER")

func _on_button_2_pressed():
	var Biomes = [ BiomeBackup[4], BiomeBackup[1] ]
	print('button2')
	generate(Biomes, "FROG")

func _on_button_pressed():
	var Biomes = [ BiomeBackup[2], BiomeBackup[3] ]
	generate(Biomes, "WOF")


func _on_button_q_pressed():
	pass # Replace with function body.
