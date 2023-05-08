extends Node2D

var target_angle
var velocity
var baseSpeed = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setTarget(targetSent):
	#target = Vector2(targetSent.position.x, targetSent.position.y)
	position.x += 8
	position.y += 8
	target_angle = get_angle_to(Vector2(targetSent.global_position.x + 8, targetSent.global_position.y + 8))
	var target_distance = sqrt(pow(global_position.x - targetSent.global_position.x + 8, 2) + pow(global_position.y - targetSent.global_position.y + 8, 2))
	print(target_distance)
	#target_angle = get_angle_to(targetSent.global_position)
	velocity = Vector2(cos(target_angle), sin(target_angle)) * (baseSpeed + pow(target_distance/10, 2))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target_angle != null:
		position += velocity * delta
