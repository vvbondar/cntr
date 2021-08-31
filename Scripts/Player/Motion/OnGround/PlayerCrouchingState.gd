extends "res://Scripts/Player/PlayerBaseState.gd"

class_name PlayerCrouchingState

func Enter() -> void:
	ChangeVelocityX(lerp(fsm.host.playerVelocity.x, 0, 1))

func Update(_delta):
	if Helper.AllDirectionsPressed():
		TransitionTo(StateTypes.IDLE)
	
	# Stay in CROUCHING state immovable if both directions applied
	if Helper.BothHorizontalDirectionsPressed():
		ChangeVelocityX(lerp(fsm.host.playerVelocity.x, 0, 1))
		
		if Input.is_action_just_released("gp_crouch"):
			TransitionTo(StateTypes.IDLE)
		else:
			return
	
	if Helper.AnyHorizontalDirectionPressed():
		TransitionTo(StateTypes.RUNNING)
	
	if Input.is_action_just_released("gp_crouch") or Input.is_action_pressed("gp_up"):
		TransitionTo(StateTypes.IDLE)
		
	elif Input.is_action_just_pressed("gp_jump"):
		# Drop only through one-way platforms
		if fsm.host.isOnOneWayPlatform:
			fsm.host.set_collision_mask_bit(GlobalConstants.LAYER_PLATFORMS_MASK_BIT, false)
			TransitionTo(StateTypes.FALLING)
