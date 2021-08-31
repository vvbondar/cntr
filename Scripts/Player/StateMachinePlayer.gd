extends 'res://Scripts/StateMachine/StateMachineBase.gd'

class_name StateMachinePlayer

func _ready():
	# Wait for fsm's host to be ready to get the body animation player nodes
	yield(get_tree().root, "ready")
	EventBus.emit_signal("STATE_CHANGED", StateTypes.JUMPING)
