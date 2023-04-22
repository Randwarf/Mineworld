extends Node2D

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
	biomeClass.new("Hard2",  0.25, Color(0,0,0.5), 0.1, true)
]
			
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func generate(Biomes):
	var grid = preload("res://GridScene.tscn")
	grid = grid.instantiate()
	
	
	add_child(grid)
	grid.generate(Biomes)
	
	get_node("Control").visible=false
	get_node("Control2").visible=false
	get_node("Control3").visible=false
	

func _on_Control_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var Biomes = [ BiomeBackup[0], BiomeBackup[1] ]
			generate(Biomes)
			
func _on_Control2_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var Biomes = [ BiomeBackup[2], BiomeBackup[3] ]
			generate(Biomes)


func _on_Control3_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var Biomes = [ BiomeBackup[4], BiomeBackup[5] ]
			generate(Biomes)
