extends Node

const DEBUG = true

static func RoundVector(vector : Vector2):
	return Vector2(round(vector.x), round(vector.y))

static func Log(node : Node, msg : String) -> void:
	print_debug(str(node.name) + ": " + msg)
	
static func AnyHorizontalDirectionPressed() -> bool:
	return Input.is_action_pressed("gp_moveLeft") or Input.is_action_pressed("gp_moveRight")
	
static func AnyVerticalDirectionPressed() -> bool:
	return Input.is_action_pressed("gp_up") or Input.is_action_pressed("gp_crouch")
	
static func BothHorizontalDirectionsPressed() -> bool:
	return Input.is_action_pressed("gp_moveLeft") and Input.is_action_pressed("gp_moveRight")
	
static func NoHorizontalDirectionsPressed() -> bool:
	return not Input.is_action_pressed("gp_moveLeft") and not Input.is_action_pressed("gp_moveRight")
	
static func BothVerticalDirectionsPressed() -> bool:
	return Input.is_action_pressed("gp_up") and Input.is_action_pressed("gp_crouch")
	
static func AllDirectionsPressed() -> bool:
	return Input.is_action_pressed("gp_moveLeft") and Input.is_action_pressed("gp_moveRight") and Input.is_action_pressed("gp_up") and Input.is_action_pressed("gp_crouch")
	#print("[" + SystemTime.new().GetTimeStamp() + "]: "+ node.name + ": " + msg)
	# GDScript: Ternary operator (a if cond else b)

static func Equal(rhs : float, lhs : float, epsilon : float = 0.001):
	return abs(rhs - lhs) < epsilon

static func IsObjectHitLayer(object : Object, point : Vector2, bit : int) -> bool:
	var spaceState = object.get_world_2d().direct_space_state
	var results = spaceState.intersect_point(point, 1, [], bit)
	#print(point)
	return results.size() > 0

static func IsStraightDirection(direction : int) -> bool:
	return (
		direction == AimDirection.RIGHT or \
		direction == AimDirection.LEFT  or \
		direction == AimDirection.DOWN  or \
		direction == AimDirection.UP
		)
		
static func IsAngledDirection(direction : int) -> bool:
	return (
		direction == AimDirection.RIGHT_UP   or \
		direction == AimDirection.LEFT_UP    or \
		direction == AimDirection.LEFT_DOWN  or \
		direction == AimDirection.RIGHT_DOWN
		)
