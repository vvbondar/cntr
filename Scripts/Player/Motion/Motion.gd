"""
var host = null
var axisInput : Vector2

func Init(_host : Node):
	host = _host

func Enter():
	.Enter()
	
func Update(delta):
	axisInput = GetInputAxis()
	
	if axisInput.x > 0:
		UpdateSpriteFlipDirection(true)
	elif axisInput.x < 0:
		UpdateSpriteFlipDirection(false)

func GetInputAxis():
	var axis = Vector2.ZERO
	axis.x = Input.get_action_strength('gp_moveRight') - Input.get_action_strength('gp_moveLeft')
	#axis.y = Input.get_action_strength()
	
	return axis
	
func UpdateSpriteFlipDirection(shouldSetFaceRight : bool):
	if host == null:
		push_error('host isn't set')
		return
		
	host.SetLookDirection(shouldSetFaceRight)
	
	if shouldSetFaceRight:
		host.debugInfo.DirectionLabel.text = 'right'
	else:
		host.debugInfo.DirectionLabel.text = 'left'
"""
