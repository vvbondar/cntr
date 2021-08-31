extends 'res://Scripts/Player/PlayerBaseState.gd'

class_name PlayerJumpingState

func Enter():
	if fsm.GetPreviousState() != null:
		ChangeVelocityY(GlobalConstants.JUMPFORCE)
		
		if fsm.GetPreviousState().GetType() == StateTypes.RUNNING:
			ChangeVelocityX(GlobalConstants.PLAYER_HORIZONTAL_SPEED_JUMPING_FROM_RUN * (-1 if fsm.host.horizontalFlip else 1))
	
func Update(_delta):
	if Input.is_action_pressed("gp_moveLeft"):
		if not Input.is_action_pressed("gp_moveRight"):
			ChangeVelocityX(-GlobalConstants.PLAYER_HORIZONTAL_SPEED_JUMPING_IN_AIR)
	
	if Input.is_action_pressed("gp_moveRight"):
		if not Input.is_action_pressed("gp_moveLeft"):
			ChangeVelocityX(GlobalConstants.PLAYER_HORIZONTAL_SPEED_JUMPING_IN_AIR)
	
	if fsm.host.IsOnSurface(WorldAreas.PLATFORMS) and fsm.host.playerVelocity.y > 64.0:
		ChangeVelocityY(64.0)
		if Helper.AnyHorizontalDirectionPressed():
			TransitionTo(StateTypes.RUNNING)
		else:
			TransitionTo(StateTypes.IDLE)
	elif fsm.host.IsOnSurface(WorldAreas.WATER):
		TransitionTo(StateTypes.SWIMMING)
	else:
		ChangeVelocityY(fsm.host.playerVelocity.y + GlobalConstants.GRAVITY_FACTOR)
