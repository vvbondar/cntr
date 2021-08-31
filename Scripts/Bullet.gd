extends KinematicBody2D

class_name Bullet

var angle 				: Vector2 			= Vector2.ZERO
var type 				: int 				= WeaponType.STANDARD
var player 				: KinematicBody2D 	= null
var playerFlip 			: bool 				= false
var playerIdx 			: int 				= -1
var playerAimDirection 	: int 				= -1

var flameDelta 			: float 			= 0.0
var flameRadius 		: float 			= 512.0
var flameRotationSpeed 	: float 			= 32.0

const animationMap = {
	WeaponType.STANDARD 	: "standard",
	WeaponType.MACHINE_GUN 	: "machine_gun",
	WeaponType.SPREAD_GUN 	: "spread_gun",
	WeaponType.FLAMETHROWER : "flamethrower",
	WeaponType.LASER 		: "laser"
}

func _ready():
	$AnimationPlayer.play("none")
	$AnimatedSprite.animation = "none"

func Init(weaponType : int, _player : KinematicBody2D, flowAngle : Vector2) -> Object:
	type = weaponType
	angle = flowAngle
	player = _player
	playerIdx = _player.playerIdx
	playerFlip = _player.horizontalFlip
	playerAimDirection = _player.aimDirection
	
	if type == WeaponType.FLAMETHROWER:
		AdjustFlamethrowerProjectileStartPosition()
	
	return self

var animationFlick : bool = true
var flickEnabled : bool = true

func _physics_process(delta):
	if angle == Vector2.ZERO:
		return
	
	if flickEnabled:
		visible = animationFlick
		animationFlick = not animationFlick
	
	var animationName : String = ""
	
	if type == WeaponType.LASER:
		#if Helper.IsStraightDirection(playerAimDirection):
		if Helper.IsStraightDirection(GlobalConstants.angleVectorToEnum[angle]):
			animationName = animationMap[type] + "_straight"
		if Helper.IsAngledDirection(GlobalConstants.angleVectorToEnum[angle]):
			animationName = animationMap[type] + "_angled"
	else:
		animationName = animationMap[type]
	
	$AnimationPlayer.play(animationName)
	
	match type:
		WeaponType.SPREAD_GUN:
			translate(angle * GlobalConstants.BULLET_SPEED_PLAYER * 0.85 * delta)
		WeaponType.FLAMETHROWER:
			translate(ComputeFlamethrowerProjectileOffset(delta))
		WeaponType.LASER:
			UpdateLaserProjectileRotation()
			translate(angle * GlobalConstants.BULLET_SPEED_PLAYER * delta)
		_:
			translate(angle * GlobalConstants.BULLET_SPEED_PLAYER * delta)
	
	$Hitbox.position = $AnimatedSprite.position
	
	#print(visible)
	
	if Helper.IsObjectHitLayer(self, $Hitbox.global_position, GlobalConstants.LAYER_PLAYER_BULLETS_MASK_BIT):
		queue_free()

func AdjustFlamethrowerProjectileStartPosition() -> void:
	var adjustmentVector = Vector2.ZERO
	
	match playerAimDirection:
		AimDirection.RIGHT:
			adjustmentVector = Vector2(3.0, 5.0)
		AimDirection.RIGHT_UP:
			adjustmentVector = Vector2(7.0, 2.0)
		AimDirection.RIGHT_DOWN:
			adjustmentVector = Vector2(4.0, 9.0)
		AimDirection.LEFT:
			adjustmentVector = Vector2(-2.0, 5.0) 
		AimDirection.LEFT_UP:
			adjustmentVector = Vector2(-7.0, 2.0)
		AimDirection.LEFT_DOWN:
			adjustmentVector = Vector2(-4.0, 9.0)
		AimDirection.UP:
			adjustmentVector = Vector2(-6.0, -5.0) if player.horizontalFlip else Vector2(6.0, -5.0)
		AimDirection.DOWN:
			adjustmentVector = Vector2(-2.0, -10.0)	
	
	$AnimatedSprite.position += adjustmentVector

func ComputeFlamethrowerProjectileOffset(delta : float) -> Vector2:
	flameDelta += delta
	
	var rotationComponentX = 0.0
	var rotationComponentY = 0.0
	
	if playerAimDirection == AimDirection.RIGHT:
		rotationComponentX = cos(flameDelta * flameRotationSpeed - deg2rad(120))
		rotationComponentY = sin(flameDelta * flameRotationSpeed - deg2rad(120))
	elif playerAimDirection == AimDirection.RIGHT_UP:
		rotationComponentX = cos(flameDelta * flameRotationSpeed - deg2rad(170))
		rotationComponentY = sin(flameDelta * flameRotationSpeed - deg2rad(170))
	elif playerAimDirection == AimDirection.RIGHT_DOWN:
		rotationComponentX = cos(flameDelta * flameRotationSpeed - deg2rad(75))
		rotationComponentY = sin(flameDelta * flameRotationSpeed - deg2rad(75))
	elif playerAimDirection == AimDirection.LEFT:
		rotationComponentX = sin(flameDelta * flameRotationSpeed + deg2rad(150))
		rotationComponentY = cos(flameDelta * flameRotationSpeed + deg2rad(150))
	elif playerAimDirection == AimDirection.LEFT_UP:
		rotationComponentX = sin(flameDelta * flameRotationSpeed + deg2rad(100))
		rotationComponentY = cos(flameDelta * flameRotationSpeed + deg2rad(100))
	elif playerAimDirection == AimDirection.LEFT_DOWN:
		rotationComponentX = sin(flameDelta * flameRotationSpeed + deg2rad(195))
		rotationComponentY = cos(flameDelta * flameRotationSpeed + deg2rad(195))
	elif playerAimDirection == AimDirection.UP:
		if playerFlip == true:
			rotationComponentX = sin(flameDelta * flameRotationSpeed + deg2rad(45))
			rotationComponentY = cos(flameDelta * flameRotationSpeed + deg2rad(45))
		else:
			rotationComponentX = cos(flameDelta * flameRotationSpeed - deg2rad(225))
			rotationComponentY = sin(flameDelta * flameRotationSpeed - deg2rad(225))
	elif playerAimDirection == AimDirection.DOWN:
		rotationComponentX = sin(flameDelta * flameRotationSpeed + deg2rad(275))
		rotationComponentY = cos(flameDelta * flameRotationSpeed + deg2rad(275))
	
	return Vector2(
		rotationComponentX * flameRadius, 
		rotationComponentY * flameRadius
		) * delta + angle * GlobalConstants.BULLET_SPEED_PLAYER / 140

func UpdateLaserProjectileRotation() -> void:
	match GlobalConstants.angleVectorToEnum[angle]:
		AimDirection.RIGHT:
			$AnimatedSprite.rotation_degrees = 90.0
		AimDirection.RIGHT_UP:
			$AnimatedSprite.rotation_degrees = 0.0
			$AnimatedSprite.flip_v = false
		AimDirection.RIGHT_DOWN:
			$AnimatedSprite.rotation_degrees = 0.0
			$AnimatedSprite.flip_v = true
		AimDirection.LEFT:
			$AnimatedSprite.rotation_degrees = -90.0
		AimDirection.LEFT_UP:
			$AnimatedSprite.rotation_degrees = 0.0
			$AnimatedSprite.flip_h = true
			$AnimatedSprite.flip_v = false
		AimDirection.LEFT_DOWN:
			$AnimatedSprite.rotation_degrees = 0.0
			$AnimatedSprite.flip_h = true
			$AnimatedSprite.flip_v = true
		#AimDirection.UP:
		#	$AnimatedSprite.rotation_degrees = 0.0
		#AimDirection.DOWN:
		#	$AnimatedSprite.rotation_degrees = 0.0
