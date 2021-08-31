extends AnimationPlayer

const shootingAnimations = ["crouching_shoot"]

func _ready():
	var RESULT = EventBus.connect("PLAYER_BODY_ANIMATION_CHANGED", self, "OnAnimationChanged", [])

func _physics_process(_delta):
	if current_animation == "diving":
		# Not using 'yield(self, "animation_finished")' because of (possibly) signal dispatching delay 
		# causing rapid (for ~1 frame) upper 'idle' animation flickering 
		#if get_parent().frame == 2:
		#	EventBus.emit_signal("PLAYER_BODY_ANIMATION_CHANGED", BodyPart.UPPER, "idle_in_water")
		pass


var prevAnim = ""
var currAnim = ""

func OnAnimationChanged(bodyPart, animationName, forced):
	if bodyPart != BodyPart.FULL:
		return
		
	prevAnim = currAnim
	currAnim = animationName
	
	if shootingAnimations.has(prevAnim) and prevAnim == currAnim:
	#	print("repeat")
		stop(true)
		play(animationName)
