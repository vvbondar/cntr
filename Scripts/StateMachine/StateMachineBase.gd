extends Node

class_name StateMachineBase

export(NodePath) var hostPath = '../'

var host = null
var statesMap = {}

var currentState  : StateBase = null setget SetCurrentState,  GetCurrentState
var previousState : StateBase = null setget SetPreviousState, GetPreviousState

func _ready():
	host = get_node(hostPath)
	if host != null:
		InitStatesMap()
		ConnectSignals()
	else:
		push_error("StateMachine\'s host is null. Player Node should be set in StateMachine\'s Inspector")
		
	

func InitStatesMap():
	for child in get_children():
		if child is StateBase:
			var type = child.GetType()
			
			if type != StateTypes.NONE:
				statesMap[type] = child
				child.fsm = self
				print_debug(StateTypes.ToString(type) + ' state of ' + host.name + ' added to ' + self.name)
			else:
				push_error(child.name + "\'s type is " + StateTypes.ToString(type) + ". Check it in Inspector window")
		else:
			push_error("\'" + child.name + "\' is not a StateBase class object. Did you attached a StateBase-inherited script to it?")

func AddState(state):
	if not statesMap.has(state.type):
		statesMap[state.type] = state

func _physics_process(delta):
	if currentState != null:
		currentState.Update(delta)
		
func _unhandled_input(inputEvent : InputEvent) -> void:
	if currentState != null:
		currentState.HandleInput(inputEvent)
		
func ChangeState(newState : StateBase) -> void:
	SetPreviousState(currentState)
	SetCurrentState(newState)
	LogTransition()

func SetCurrentState(newState : StateBase) -> void:
	if newState != null:
		if statesMap.has(newState.GetType()):
			currentState = newState
			currentState.Enter()
		else:
			push_error('No ' + newState.GetStateName() + ' found in StatesMap')
	else:
		push_error(self.name + ": SetCurrentState(null)")

func GetCurrentState() -> StateBase:
	return currentState
		
func SetPreviousState(newState : StateBase):
	if newState != null:
		previousState = newState
		previousState.Exit()
		
func GetPreviousState():
	return previousState

# Hinting parameter as int to get the type check work
func GetStateFromStatesMap(type : int) -> StateBase:
	if type != StateTypes.NONE:
		return statesMap[type]
	else:
		push_error(self.name + ": GetStateFromStatesMap(" + String(type) + ") got NONE stateType to get from statesMap. Returning null")
		return null

func CurrentStateIs(type : int) -> bool:
	return GetCurrentState() == GetStateFromStatesMap(type)
	
func PreviousStateIs(type : int) -> bool:
	return GetPreviousState() == GetStateFromStatesMap(type)

func LogTransition():
	var prevStateStr = "null"
	
	if previousState != null:
		prevStateStr = previousState.GetStateName()
	
	var currStateStr = currentState.GetStateName()
	
	#Helper.Log(self, "ChangeState(): " + prevStateStr + " -> " + currStateStr)
func ConnectSignals() -> void:
	var RESULT = EventBus.connect("STATE_CHANGED", self, "OnStateChanged", [])

func OnStateChanged(newState: int) -> void:
	ChangeState(GetStateFromStatesMap(newState))
