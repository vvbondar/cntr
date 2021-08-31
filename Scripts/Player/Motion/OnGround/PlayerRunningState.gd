extends 'res://Scripts/Player/PlayerBaseState.gd'

class_name PlayerRunningState

func Update(_delta : float) -> void:
	# TODO: Check super-jump bug upon walking off edge and jumping
	# TODO: need to force return upon transitions to stop handling inputs from Update
	if not fsm.host.IsOnSurface(WorldAreas.PLATFORMS):
		if not fsm.host.IsOnSurface(WorldAreas.WATER): #and not fsm.PreviousStateIs(StateTypes.CLIMBING):
			TransitionTo(StateTypes.FALLING)
			return
		else:
			TransitionTo(StateTypes.SWIMMING)
			return
	else:
		if Helper.AllDirectionsPressed():
			TransitionTo(StateTypes.IDLE)
			return
	
		if Helper.NoHorizontalDirectionsPressed():
			TransitionTo(StateTypes.IDLE)
			return
	
		if Input.is_action_pressed("gp_moveLeft"):
			ChangeVelocityX(-GlobalConstants.PLAYER_HORIZONTAL_SPEED_WALKING)
		
			# Transit to IDLE if opposite movement direction applied
			if Input.is_action_pressed("gp_moveRight"):
				TransitionTo(StateTypes.IDLE)
			
		# Same goes for the right direction
		elif Input.is_action_pressed("gp_moveRight"):
			ChangeVelocityX(GlobalConstants.PLAYER_HORIZONTAL_SPEED_WALKING)

			if Input.is_action_pressed("gp_moveLeft"):
				TransitionTo(StateTypes.IDLE)
		
		if Input.is_action_just_released("gp_crouch") or Input.is_action_just_released("gp_up"):
			pass	
		elif Input.is_action_just_released("gp_moveLeft") or Input.is_action_just_released("gp_moveRight"):
			TransitionTo(StateTypes.IDLE)
	
		if Input.is_action_just_pressed("gp_jump"):
			TransitionTo(StateTypes.JUMPING)
			return

