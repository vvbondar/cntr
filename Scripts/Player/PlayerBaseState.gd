extends "res://Scripts/StateMachine/StateBase.gd"

class_name PlayerBaseState

#var upperBodyAnimationPlayer = null
#var lowerBodyAnimationPlayer = null

func _ready():
	yield(get_tree().root, "ready")
	
#func _physics_process(_delta) -> void:
#	print(fsm.host.IsOnSurface(WorldAreas.KILLBOX))

func ChangeVelocityX(newValue : float) -> void:
	EventBus.emit_signal("X_VELOCITY_CHANGED", newValue)
	
func ChangeVelocityY(newValue : float) -> void:
	EventBus.emit_signal("Y_VELOCITY_CHANGED", newValue)

func FallFromEdge() -> void:
	ChangeVelocityX(GlobalConstants.PLAYER_HORIZONTAL_SPEED_FALLING_OFF_EDGE * (-1 if fsm.host.horizontalFlip else 1))
