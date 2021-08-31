extends AnimatedSprite

var phase : bool = true
var timer : Timer = null
onready var ac = get_parent().get_parent().find_node("AnimationController")

func _ready():
	var RESULT = EventBus.connect("PLAYER_BODY_ANIMATION_CHANGED", self, "OnPlayerBodyAnimationChanged", [])
	
	timer = Timer.new()
	timer.wait_time = 0.26
	timer.one_shot = false
	timer.connect("timeout", self, "OnRepeat")
	add_child(timer)

func OnPlayerBodyAnimationChanged(_bodyPart : int, _animationName : String, _forced : bool):
	if ac.currentState != StateTypes.SWIMMING:
		timer.stop()
		return
	
	if 	 get_child(0).current_animation == "under_water":	position.y = 7.0
	elif get_child(0).current_animation == "idle_in_water":	
		position.x = 0.0
		position.y = 5.0
	else: 
		timer.stop()
		return
		
	phase = true
	timer.start()

func OnRepeat():
	position.y += 1 if phase else -1
	phase = not phase
	
	#print("OnRepeat(" + str(phase) + ")")
