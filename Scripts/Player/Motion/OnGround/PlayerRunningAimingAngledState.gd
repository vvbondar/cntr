extends "res://Scripts/Player/Motion/OnGround/PlayerRunningState.gd"

class_name PlayerRunningAimingAngledState

func Update(_delta):
	if Input.is_action_just_released("gp_up"):
		TransitionTo(StateTypes.RUNNING)
