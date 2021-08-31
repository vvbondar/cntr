extends VBoxContainer

export(NodePath) var StateMachine

func _ready():
	for child in get_children():
		child.add_color_override("font_color", Color(255, 255, 0, 1))

func SetStateString(state : String):
	$StateLabel.text = state

func SetDirectionString(direction : Vector2):
	$DirectionLabel.text = String(direction)

func SetPositionString(position : Vector2):
	$PositionLabel.text = String(position)
#func _physics_process(delta):
#	SetStateString(get_node(StateMachine).currentState.name)
