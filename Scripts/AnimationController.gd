extends Node

# autoload
class_name AnimationController

var previousAnimations = {
	BodyPart.UPPER : "",
	BodyPart.LOWER : "",
	BodyPart.FULL  : ""
}

var currentAnimations = {
	BodyPart.UPPER : "",
	BodyPart.LOWER : "",
	BodyPart.FULL  : ""
}

var currentState = StateTypes.NONE
var currentFlip = false
var currentAimingDirection = null
var stack = []

func _ready():
	var RESULT = EventBus.connect("STATE_CHANGED", self, "OnStateChanged", [])

# Input-dependent animation handling
func _physics_process(_delta):
	UpdateFlip()
	
	match currentState:
		StateTypes.NONE:
			return
			
		StateTypes.IDLE:
			# Blocks below implement simultaneous UP and DOWN press
			if Input.is_action_pressed("gp_up"):
				if not Input.is_action_pressed("gp_crouch"):
					if not currentAnimations[BodyPart.UPPER] == "aiming_up_shoot":
						EmitAnimationChangeSignal(BodyPart.UPPER, "aiming_up")
				else:
					# UP + DOWN put player to regular IDLE animation
					EmitAnimationChangeSignal(BodyPart.UPPER, "idle")
					
			if Input.is_action_just_released("gp_up"):
				if not Input.is_action_pressed("gp_crouch"):
					EmitAnimationChangeSignal(BodyPart.UPPER, "idle")

		StateTypes.RUNNING:
			if Input.is_action_pressed("gp_moveLeft") or Input.is_action_pressed("gp_moveRight"):
				if Input.is_action_pressed("gp_up") and not Input.is_action_pressed("gp_crouch"):
					if not currentAnimations[BodyPart.UPPER] == "running_angled_shoot":
						EmitAnimationChangeSignal(BodyPart.UPPER, "aiming_angled")
					
			if Input.is_action_pressed("gp_crouch"):
				if not Input.is_action_pressed("gp_up"):
					if not currentAnimations[BodyPart.UPPER] == "running_down_shoot":
						EmitAnimationChangeSignal(BodyPart.UPPER, "aiming_down")
			
			if Input.is_action_just_released("gp_crouch") or Input.is_action_just_released("gp_up"):
				EmitAnimationChangeSignal(BodyPart.UPPER, "running")
			
		StateTypes.SWIMMING:
			if Input.is_action_pressed("gp_crouch"):
				if not Input.is_action_pressed("gp_up"):
					#if not currentAnimations[BodyPart.FULL] == "diving" and not currentAnimations[BodyPart.UPPER] == "under_water":
					EmitAnimationChangeSignal(BodyPart.UPPER, "under_water")
				else:
					if not currentAnimations[BodyPart.UPPER] == "in_water_shoot":
						EmitAnimationChangeSignal(BodyPart.UPPER, "idle_in_water")
					
			#if Input.is_action_just_pressed("gp_up"):
			#		EmitAnimationChangeSignal(BodyPart.UPPER, "idle_in_water")
				
			if Input.is_action_just_released("gp_crouch"):
				EmitAnimationChangeSignal(BodyPart.UPPER, "idle_in_water")
			
			#elif Input.is_action_just_released("gp_crouch") or Input.is_action_pressed("gp_up"):
			#	if currentAnimations[BodyPart.UPPER] == "under_water":
			#		EmitAnimationChangeSignal(BodyPart.UPPER, "idle_in_water")
					
			
	UpdateFlip()
	
# Initial animations change handling
func OnStateChanged(newState : int) -> void:
	match newState:
		StateTypes.NONE:
			return
		StateTypes.IDLE:
			EmitAnimationChangeSignal(BodyPart.UPPER, "idle")
			EmitAnimationChangeSignal(BodyPart.LOWER, "idle")
		StateTypes.JUMPING:
			EmitAnimationChangeSignal(BodyPart.FULL, "jumping")
		StateTypes.FALLING:
			EmitAnimationChangeSignal(BodyPart.FULL, "falling")
		StateTypes.RUNNING:
			#print("RUNNING " + str(get_tree().get_frame()))
			EmitAnimationChangeSignal(BodyPart.UPPER, "running")
			EmitAnimationChangeSignal(BodyPart.LOWER, "running")
		StateTypes.CROUCHING:
			EmitAnimationChangeSignal(BodyPart.FULL, "crouching")
		StateTypes.SWIMMING:
			EmitAnimationChangeSignal(BodyPart.FULL, "diving")
		StateTypes.CLIMBING:
			EmitAnimationChangeSignal(BodyPart.UPPER, "up_on_shore")
			EmitAnimationChangeSignal(BodyPart.LOWER, "none")

	currentState = newState

func EmitAnimationChangeSignal(bodyPart : int, animationName : String, forced : bool = false, fromShootingAnimation = false) -> void:
	if bodyPart == BodyPart.NONE:
		return
	
	if currentAnimations[bodyPart] == animationName and not forced:
		return
		
	if fromShootingAnimation:
		if 	currentState == StateTypes.CROUCHING or \
			currentState == StateTypes.JUMPING 	 or \
			currentState == StateTypes.FALLING:
			return
		if currentAnimations[BodyPart.FULL] != "none":
			return	
	
	UpdateFlip()
	
	EventBus.emit_signal("PLAYER_BODY_ANIMATION_CHANGED", bodyPart, animationName, forced)
	#if bodyPart == BodyPart.UPPER:
	#	print("EmitAnimationChangeSignal(" + animationName + ", " + str(forced) + (", fromShoot" if fromShootingAnimation else "") + ") " + "[" + str(get_tree().get_frame()) + "]")
	
	if bodyPart == BodyPart.UPPER or bodyPart == BodyPart.LOWER:
		currentAnimations[BodyPart.FULL] = "none"
	else:
		currentAnimations[BodyPart.UPPER] = "none"
		currentAnimations[BodyPart.LOWER] = "none"
			
	previousAnimations[bodyPart] = currentAnimations[bodyPart]
	currentAnimations[bodyPart] = animationName

func UpdateFlip() -> void:
	#if currentState == StateTypes.SWIMMING:
	#	return
	
	if Input.is_action_pressed("gp_moveLeft") or Input.is_action_pressed("gp_moveRight"):
		if not Helper.BothHorizontalDirectionsPressed():
			var flip = Input.get_action_strength("gp_moveRight") - Input.get_action_strength("gp_moveLeft") < 0
			if currentFlip != flip:
				currentFlip = flip
				EventBus.emit_signal("PLAYER_BODY_H_FLIP_CHANGED", flip)
