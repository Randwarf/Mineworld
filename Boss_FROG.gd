extends Node2D

const TIME_BETWEEN_JUMPS = 5
const TIME_UNTIL_LOCK_IN = 4

var CooldownTimer
var LockInTimer
var TargetSprite
var isJumping = false
var jumpTime
var target
var targetInGrid
var player
var Scene

# Called when the node enters the scene tree for the first time.
func _ready():
	CooldownTimer = get_node("Cooldown")
	LockInTimer = get_node("LockIn")
	TargetSprite = get_node("Target")

func setTarget():
	targetInGrid = Scene.getPlayerPos()
	target = Vector2(targetInGrid.c, targetInGrid.r)*16

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isJumping:
		position = position.lerp(target, delta*10)
		if (position - target).length() < 0.001:
			isJumping = false
			CooldownTimer.wait_time*0.95
			CooldownTimer.start()
			LockInTimer.wait_time*0.95
			LockInTimer.start()
			Scene.clearMapAreaAnywhere(targetInGrid, 2) #idk
			

func displayTarget():
	TargetSprite.visible=true
	TargetSprite.position = target-position
func hideTarget():
	TargetSprite.visible=false

func _on_cooldown_timeout():
	isJumping = true
	hideTarget()

func _on_lock_in_timeout():
	setTarget()
	displayTarget()
