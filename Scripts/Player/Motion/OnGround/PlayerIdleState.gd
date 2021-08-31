extends 'res://Scripts/Player/PlayerBaseState.gd'

class_name PlayerIdleState

func Update(_delta : float) -> void:
	if fsm.host.IsOnSurface(WorldAreas.PLATFORMS):
		if Helper.NoHorizontalDirectionsPressed():
			ChangeVelocityX(lerp(fsm.host.playerVelocity.x, 0, 1))
		
		#if fsm.host.playerVelocity != Vector2(0.0, 64.0):
		#	FallFromEdge() 
		
		if Input.is_action_just_pressed('gp_jump'):
			TransitionTo(StateTypes.JUMPING)
			return
		elif Input.is_action_pressed("gp_moveLeft"):
			if not Input.is_action_pressed("gp_moveRight"):
				TransitionTo(StateTypes.RUNNING)
			else:
				ChangeVelocityX(lerp(fsm.host.playerVelocity.x, 0, 1))
		elif Input.is_action_pressed("gp_moveRight"):
			if not Input.is_action_pressed("gp_moveLeft"):
				TransitionTo(StateTypes.RUNNING)
			else:
				ChangeVelocityX(lerp(fsm.host.playerVelocity.x, 0, 1))
				
		if Input.is_action_pressed("gp_crouch"):
			if not Input.is_action_pressed("gp_up"):
				TransitionTo(StateTypes.CROUCHING)
				
		ChangeVelocityY(GlobalConstants.BASE_GRAVITY)
	else:
		# This transition exists only to bypass sliding off platform edge bug
		if not fsm.PreviousStateIs(StateTypes.JUMPING) and not fsm.PreviousStateIs(StateTypes.SWIMMING):
			TransitionTo(StateTypes.FALLING)
		
func Enter():
	# Need to compensate 1 frame of movement due to next check
	#if fsm.PreviousStateIs(StateTypes.JUMPING) or fsm.PreviousStateIs(StateTypes.FALLING):
	#	fsm.host.global_position.x += 1 if fsm.host.horizontalFlip else -1
	
	#and not Helper.AnyHorizontalDirectionPressed() and fsm.host.playerVelocity.x != 0:
	
	#if (fsm.host.IsOnSurface(WorldAreas.PLATFORMS) and not Helper.AnyHorizontalDirectionPressed()) or \
	#(fsm.PreviousStateIs(StateTypes.SWIMMING) and not Helper.AnyHorizontalDirectionPressed()):
	#	ChangeVelocityX(lerp(fsm.host.playerVelocity.x, 0, 1))
	
	if not Helper.AnyHorizontalDirectionPressed():
		#if fsm.host.IsOnSurface(WorldAreas.PLATFORMS) or fsm.PreviousStateIs(StateTypes.SWIMMING):
		ChangeVelocityX(lerp(fsm.host.playerVelocity.x, 0, 1))
	

	#if fsm.GetPreviousState().GetType() == StateTypes.RUNNING and round(fsm.host.playerVelocity.y) != 64.0:
	#	FallFromEdge()

