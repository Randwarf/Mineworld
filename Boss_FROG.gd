extends Node2D

const TIME_BETWEEN_JUMPS = 5
const TIME_UNTIL_LOCK_IN = 4

var health
var CooldownTimer
var LockInTimer
var TargetSprite
var FrogSprite
var isJumping = false
var jumpTime
var target
var targetInGrid
var player
var Scene
var audio

# Called when the node enters the scene tree for the first time.
func _ready():
	CooldownTimer = get_node("Cooldown")
	LockInTimer = get_node("LockIn")
	TargetSprite = get_node("Target")
	FrogSprite = get_node("FrogSprite")
	FrogSprite.play()
	audio = get_node("AudioStreamPlayer2D")
	health = 25
	FrogSprite.modulate = Color(1-health/25.0, health/25.0, 0)
	

func setTarget():
	targetInGrid = Scene.getPlayerPos()
	target = Vector2(targetInGrid.c, targetInGrid.r)*16

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isJumping:
		position = position.lerp(target, delta*10)
		if (position - target).length() < 1:
			position = target
			isJumping = false
			FrogSprite.animation="Land"
			FrogSprite.play()
			CooldownTimer.wait_time = CooldownTimer.wait_time * 0.98
			CooldownTimer.start()
			LockInTimer.wait_time = LockInTimer.wait_time * 0.98
			LockInTimer.start()
			health -= countMines()
			print(Color(1.0-health/25.0, 1.0,1.0))
			FrogSprite.modulate = Color(1-health/25.0, health/25.0, 0)
			
			Scene.clearMapAreaAnywhere(targetInGrid, 2) 
			if health <= 0:
				Scene.Victory()
				CooldownTimer.stop()
				LockInTimer.stop()
			elif onPlayer():
				Scene.PlayerTakeDamage()
			
func countMines():
	var sum = 0
	for r in range(position.y/16-1, position.y/16+2):
		for c in range(position.x/16-1, position.x/16+2):
			if Scene.isMine(Coordinates.new(r,c)):
				sum+=1
	return sum**2

func onPlayer():
	var ppos = Scene.getPlayerPos()
	for r in range(position.y/16-1, position.y/16+2):
		for c in range(position.x/16-1, position.x/16+2):
			if r == ppos.r and c == ppos.c:
				return true
	return false
func displayTarget():
	TargetSprite.visible=true
	TargetSprite.position = target-position+Vector2(8,8)
func hideTarget():
	TargetSprite.visible=false

func _on_cooldown_timeout():
	isJumping = true
	FrogSprite.animation="Jump"
	FrogSprite.play()
	audio.play()
	hideTarget()

func _on_lock_in_timeout():
	setTarget()
	displayTarget()
