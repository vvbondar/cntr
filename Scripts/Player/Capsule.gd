extends CollisionShape2D

var currentState : int = StateTypes.NONE

const ExtentsTable = {
	StateTypes.IDLE      : Vector2(8, 17), # pos(0, 2)
	StateTypes.RUNNING   : Vector2(8, 17),
	StateTypes.JUMPING   : Vector2(8, 10),
	StateTypes.FALLING   : Vector2(8, 17),
	StateTypes.CROUCHING : Vector2(16, 8),
}



func _ready():
	EventBus.connect("STATE_CHANGED", self, "OnStateChanged", [])
	
func _physics_process(_delta):
	if currentState == StateTypes.NONE:
		return
	
	SetExtentsByState(currentState)
	print(global_position)
	#print(String(ExtentsTable[currentState]))
	
	#if currentState == StateTypes.IDLE:
	#	position.y = 2
	#elif currentState == StateTypes.CROUCHING:
	#	position.y = -1
	#else:
	#	position.y = 0
	
	match currentState:
		StateTypes.JUMPING:
			var ray = get_parent().find_node("GroundCheckRay")
			if ray.is_colliding():
				if ray.get_collider().name == "Ground":
					SetExtentsByState(StateTypes.RUNNING)
				elif ray.get_collider().name == "WaterArea":
					pass
			else:
				position.y = 1

func OnStateChanged(newState : int) -> void:
	currentState = newState
	if currentState == StateTypes.CROUCHING:
		yield(get_parent().find_node("Body").get_child(2).get_child(0), "animation_finished")
		self.global_position.y += 10

func SetExtentsByState(state) -> void:
	if ExtentsTable.has(state) and shape.extents != ExtentsTable[state]:
		shape.extents = ExtentsTable[state]
