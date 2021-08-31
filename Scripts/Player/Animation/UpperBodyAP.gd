extends AnimationPlayer

onready var lowerBodyAP = get_node("../../LowerBody/LowerBodyAP")

var currentState = StateTypes.NONE

const shootingAnimations = [
	"idle_shoot", 
	"running_shoot", 
	"running_angled_shoot", 
	"running_down_shoot", 
	"aiming_up_shoot",
	"in_water_angled_shoot",
	"in_water_shoot",
	"in_water_up_shoot"	
	]
 
func _ready():
	var RESULT 
	RESULT = EventBus.connect("STATE_CHANGED", self, "OnStateChanged", [])
	RESULT = EventBus.connect("PLAYER_BODY_ANIMATION_CHANGED", self, "OnAnimationChanged", [])
	
	
func OnStateChanged(newState : int) -> void:
	currentState = newState
	
var prevAnim = ""
var currAnim = ""

func OnAnimationChanged(bodyPart, animationName, _forced):
	if bodyPart != BodyPart.UPPER:
		return
		
	prevAnim = currAnim
	currAnim = animationName
	
	if shootingAnimations.has(prevAnim) and prevAnim == currAnim:
	#	print("repeat")
		stop(true)
		play(animationName)
		

		#else:
	if animationName == "under_water" and prevAnim == "in_water_shoot":
		get_parent().position.x = 0.0
		#if get_node("../../../").horizontalFlip:
		#	get_parent().position.x = 1.0
		#else:
		#	get_parent().position.x = -1.0
	#else:
	#print(BodyPart.ToString(bodyPart) + " CHANGED TO " + animationName + (" [forced]" if forced else ""))


func _physics_process(_delta):
	if currentState != StateTypes.CLIMBING and not shootingAnimations.has(current_animation):
		SyncBodyParts()
		
	HandleInWaterShootFlipPosition()
	#print(asm.get("parameters/playback").get_current_node())
	#print(lowerBodyAP.get_parent().position.x)	

func HandleInWaterShootFlipPosition() -> void:
	var body_upper = get_parent()
	var body_lower = lowerBodyAP.get_parent()
	
	if  current_animation != "in_water_shoot" 	 and \
		current_animation != "in_water_up_shoot" and \
		current_animation != "in_water_angled_shoot":
			return
	
	#body_lower.position.y = 8.0
	
	match current_animation:
		"in_water_shoot":
			if get_node("../../../").horizontalFlip:
				body_upper.position.x = 4.0
			else:
				body_upper.position.x = -6.0
		
			match body_upper.frame:
				0:
					body_upper.position.y = 3.0
				1:
					body_upper.position.y = 2.0
					
		"in_water_angled_shoot":
			if get_node("../../../").horizontalFlip:
				body_upper.position.x = -3.0
			else:
				body_upper.position.x = 1.0
			
			match body_upper.frame:
				0:
					body_upper.position.y = 3.0
				1:
					body_upper.position.y = 2.0
		
		"in_water_up_shoot":
			if get_node("../../../").horizontalFlip:
				body_upper.position.x = -2.0
			else:
				body_upper.position.x = -1.0
			
			match body_upper.frame:
				0:
					body_upper.position.y = -2.0
				1:
					body_upper.position.y = -3.0
					
	#else:
	#	lowerBodyAP.play("none") 

func SetLowerBodySwimmingActive(isActive : bool) -> void:
	#if isActive and currAnim == prevAnim:
	#	return
	
	lowerBodyAP.get_parent().visible = isActive
	lowerBodyAP.play("swimming" if isActive else "none")
	
	#print("SetLowerBodySwimmingActive(" + str(isActive) + ")")


func IsLowerBodyInWobbleFrame() -> bool:
	return false
#	var currentLowerBodyAnimationPosition = 0.0
	
#	if asm.get("parameters/playback").get_current_node() != "":
#		currentLowerBodyAnimationPosition = lowerBodyAP.current_animation_position
	
#	return int(round(currentLowerBodyAnimationPosition * 100)) % 15 == 0 and \
#			(Helper.Equal(currentLowerBodyAnimationPosition, 0.15) or        \
#			 Helper.Equal(currentLowerBodyAnimationPosition, 0.6))

func SyncBodyParts() -> void:
	if current_animation != "" and lowerBodyAP.current_animation != "":
		var currentLowerBodyAnimationPosition = lowerBodyAP.current_animation_position
		
		if not Helper.Equal(current_animation_position, currentLowerBodyAnimationPosition, 0.15):
			advance(currentLowerBodyAnimationPosition)
		
	
	# ASM MODE
	"""
	var currentAnimationName = asm.get("parameters/playback").get_current_node()
	
	if currentAnimationName != "" and lowerBodyAP.current_animation != "":
		if currentAnimationName != "running_shoot":
			var currentLowerBodyAnimationPosition = lowerBodyAP.current_animation_position
		
		#print("u:" + str(asm.get("parameters/" + currentAnimationName + "/time")) + " l:" + str(currentLowerBodyAnimationPosition))
		#print(asm.get("parameters/" + currentAnimationName + "/time"))
		
			var currentAnimationPosition = asm.get("parameters/" + currentAnimationName + "/time")
		
			if not Helper.Equal(currentAnimationPosition, currentLowerBodyAnimationPosition, 0.15):
				asm.advance(currentLowerBodyAnimationPosition)
				
	"""
