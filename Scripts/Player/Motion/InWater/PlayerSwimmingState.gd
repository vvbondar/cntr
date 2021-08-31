extends "res://Scripts/Player/PlayerBaseState.gd"

var underWater : bool = false

func Enter() -> void:
	#if Helper.NoHorizontalDirectionsPressed() and fsm.host.playerVelocity.x != 0:
	ChangeVelocityX(lerp(fsm.host.playerVelocity.x, 0, 1))
		
func Exit() -> void:
	pass

func Update(_delta) -> void:
	underWater = fsm.host.ac.currentAnimations[BodyPart.UPPER] == "under_water"
	
	if not underWater:
		if Input.is_action_pressed("gp_moveLeft"):
			ChangeVelocityX(-GlobalConstants.PLAYER_HORIZONTAL_SPEED_SWIMMING)
		
		elif Input.is_action_pressed("gp_moveRight"):
			ChangeVelocityX(GlobalConstants.PLAYER_HORIZONTAL_SPEED_SWIMMING)

	#if Input.is_action_pressed("gp_crouch") and not Input.is_action_pressed("gp_up"):
	#	if not underWater:
	#		underWater = true

	#if Input.is_action_just_released("gp_crouch"):
	#	if underWater:
	#		underWater = false

	if Helper.BothHorizontalDirectionsPressed() or Input.is_action_just_released("gp_moveLeft") or Input.is_action_just_released("gp_moveRight"):
		ChangeVelocityX(lerp(fsm.host.playerVelocity.x, 0, 1))
		
		
	#print(underWater)
