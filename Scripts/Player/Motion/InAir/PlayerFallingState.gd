extends "res://Scripts/Player/PlayerBaseState.gd"

class_name PlayerFallingState

var offTheEdgeTimeoutReached : bool = false
var blockXVelocity : bool = false
var offTheEdgeTimer : Timer = null

func Enter() -> void:
	#if fsm.PreviousStateIs(StateTypes.SWIMMING):
		#if fsm.host.horizontalFlip:
	#	fsm.host.position.y += 50
	
	offTheEdgeTimer = Timer.new()
	var RESULT = offTheEdgeTimer.connect("timeout", self, "_on_timer_timeout")
	add_child(offTheEdgeTimer)
	offTheEdgeTimer.start(0.2)
	#fsm.host.inputAllowed = false

	# TODO: find out why rapid movement input after falling off edge 
	# (not triggering auto acceleration) still moves player in applied direction before timer expires
	if fsm.GetPreviousState() != null:
		if fsm.GetPreviousState().GetType() == StateTypes.RUNNING or fsm.GetPreviousState().GetType() == StateTypes.IDLE: #and fsm.host.GetClosestSurfaceName() != "Water":
			FallFromEdge()
	# Straight fall into the water
	#else:
		#ChangeVelocityX(0)
		#offTheEdgeTimer.start(3)
		#blockXVelocity = true
	
func Exit() -> void:
	offTheEdgeTimer.stop()
	offTheEdgeTimeoutReached = false
	
func Update(_delta : float) -> void:
	if not fsm.host.IsOnSurface(WorldAreas.PLATFORMS):
		fsm.host.set_collision_mask_bit(GlobalConstants.LAYER_PLATFORMS_MASK_BIT, true)
	
	if Input.is_action_pressed("gp_moveLeft"):
		if offTheEdgeTimeoutReached:# or fsm.GetPreviousState().GetType() == StateTypes.CROUCHING:
			
			ChangeVelocityX(-GlobalConstants.PLAYER_HORIZONTAL_SPEED_FALLING_IN_AIR)

	elif Input.is_action_pressed("gp_moveRight"):
		if offTheEdgeTimeoutReached:# or fsm.GetPreviousState().GetType() == StateTypes.CROUCHING:
			ChangeVelocityX(GlobalConstants.PLAYER_HORIZONTAL_SPEED_FALLING_IN_AIR)

	if fsm.host.IsOnSurface(WorldAreas.PLATFORMS):
		#if not Input.is_action_pressed("gp_jump"):
		if Helper.NoHorizontalDirectionsPressed():
			TransitionTo(StateTypes.IDLE)
		else:
			ChangeVelocityY(64.0)
			TransitionTo(StateTypes.RUNNING)
	elif fsm.host.IsOnSurface(WorldAreas.WATER):
		TransitionTo(StateTypes.SWIMMING)
	else:
		ChangeVelocityY(fsm.host.playerVelocity.y + GlobalConstants.GRAVITY_FACTOR / 1.5) #+ pow(GlobalConstants.GRAVITY_FACTOR, 2))

func _on_timer_timeout():
	offTheEdgeTimeoutReached = true
	offTheEdgeTimer.stop()
	#fsm.host.inputAllowed = true
