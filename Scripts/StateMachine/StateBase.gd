extends Node

class_name StateBase

#const StateTypes = preload('res://Scripts/Enums/StateTypes.gd')

# Reference to the state machine, to call its `transition_to()` method directly.
# The state machine node will set it.
var fsm = null

# Match the enum value from StateTypes.gd
# Custom resource export could be provided in 4.x
export(int) var stateType = 0 setget , GetType
#export(bool) var isDefault = false

# Virtual function. Receives events from the `_unhandled_input()` callback.
func HandleInput(_inputEvent : InputEvent) -> void:
	pass
	
func Update(_delta : float) -> void:
	pass
	
func Enter():
	pass
	
func Exit():
	pass

func Animate():
	pass
	
func TransitionTo(newState : int) -> void:
	#yield(get_tree().create_timer(0), "timeout")
	print(self.name + ": " + str(fsm.GetCurrentState().GetStateName()) + " -> " + fsm.GetStateFromStatesMap(newState).GetStateName())
	#fsm.ChangeState(fsm.GetStateFromStatesMap(newState))
	EventBus.emit_signal("STATE_CHANGED", newState)

func GetType() -> StateTypes:
	return stateType

func GetStateName():
	if stateType == StateTypes.NONE:
		return "null"
	else:
		return StateTypes.ToString(stateType)
