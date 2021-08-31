extends "res://Scripts/Player/PlayerBaseState.gd"

func UpOnShoreFinished() -> void:
	if Helper.AnyHorizontalDirectionPressed():
		TransitionTo(StateTypes.RUNNING) 
	else:
		TransitionTo(StateTypes.IDLE)
