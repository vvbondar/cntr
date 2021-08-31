extends Node2D

var runAnimationShifted : bool = false

func _ready():
	var RESULT = EventBus.connect("STATE_CHANGED", self, "OnStateChanged", [])
	
func OnStateChanged(newState : int) -> void:
	if newState == StateTypes.RUNNING:
		runAnimationShifted = false

func _process(_delta):
	# For smoother FALLING -> RUNNING transition
	if get_parent().fsm.PreviousStateIs(StateTypes.FALLING):
		if get_parent().fsm.CurrentStateIs(StateTypes.RUNNING):
			if runAnimationShifted == false:
				$UpperBody.frame = 3
				$LowerBody.frame = 3
				#$UpperBody/UpperBodyAP.advance(0.07)
				#$LowerBody/LowerBodyAP.advance(0.07)
				runAnimationShifted = true
