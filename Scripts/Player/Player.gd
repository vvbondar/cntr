extends KinematicBody2D

class_name Player

onready var debugInfo = $DebugInfo
onready var fsm = $StateMachinePlayer

var playerVelocity = Vector2.ZERO
var horizontalFlip : bool = false
var inputAllowed : bool = true

var currentPlatformCollider : Node = Node.new()
var isOnOneWayPlatform : bool = false
var lastCollisionShapeIdx : int = -1
var playerIdx : int = -1

export var isPlayerOne : bool = true
var currentWeapon : int = WeaponType.SPREAD_GUN
var fireRateUpdateDelta : float = 0.0
var timeElapsed : float = 0.0
var aimDirection : int = AimDirection.NONE

onready var currentLevel : Node2D = get_node("../../")

onready var bulletSpawnPoint = $BulletSpawnPoint
onready var ac = $AnimationController

var currentUpperBodyAnimation : String = ""

var staticSpawner : Vector2 = Vector2.ZERO
var laserShotInProgress : bool = false

#var laserBeams : Array = []

var bulletLimitMap = {
	WeaponType.STANDARD 	: false,
	WeaponType.MACHINE_GUN 	: false,
	WeaponType.SPREAD_GUN 	: false,
	WeaponType.FLAMETHROWER : false,
	WeaponType.LASER 		: false
}

var bulletCountMap = {
	WeaponType.STANDARD 	: 0,
	WeaponType.MACHINE_GUN 	: 0,
	WeaponType.SPREAD_GUN 	: 0,
	WeaponType.FLAMETHROWER : 0,
	WeaponType.LASER 		: 0
}

#const BULLET_SCENE = preload("res://Scenes/Bullet.tscn")

func Init(isPlayerOne : bool = true) -> Object:	
	SetIsPlayerTwo(!isPlayerOne)
	playerIdx = int(!isPlayerOne)
	
	SetCollisionLayerBitEnabled(GlobalConstants.LAYER_GENERAL_MASK_BIT, true)
	
	SetCollisionMaskBitEnabled(GlobalConstants.LAYER_GENERAL_MASK_BIT, true)
	SetCollisionMaskBitEnabled(GlobalConstants.LAYER_PLATFORMS_MASK_BIT, true)
	SetCollisionMaskBitEnabled(GlobalConstants.LAYER_WATER_MASK_BIT, true)
	SetCollisionMaskBitEnabled(GlobalConstants.LAYER_KILLBOX_MASK_BIT, true)
	
	
	OnBodyFlipChanged($Body/FullBody.flip_h)
	ConnectSignals()
	
	return self

#func _ready():
#	if not isPlayerOne:
#		SetIsPlayerTwo(true)
#		
#	playerIdx = int(!isPlayerOne)
#		
#	OnBodyFlipChanged($Body/FullBody.flip_h)
#	ConnectSignals()
	
func UpdateAimDirectionAndBulletSpawnPosition():
	match fsm.GetCurrentState().GetType():
		StateTypes.IDLE:
			match currentUpperBodyAnimation:
				"idle", "idle_shoot":
					aimDirection = AimDirection.RIGHT if not horizontalFlip else AimDirection.LEFT
					bulletSpawnPoint.position = Vector2(-13.0, -3.5) if horizontalFlip else Vector2(13.0, -3.5)
				"aiming_up", "aiming_up_shoot":
					aimDirection = AimDirection.UP
					bulletSpawnPoint.position = Vector2(-2.5, -20.0) if horizontalFlip else Vector2(2.5, -20.0)
		StateTypes.RUNNING:
			match currentUpperBodyAnimation:
				"running", "running_shoot":					
					aimDirection = AimDirection.RIGHT if not horizontalFlip else AimDirection.LEFT
					bulletSpawnPoint.position = Vector2(-13.0, -3.5) if horizontalFlip else Vector2(13.0, -3.5)
				"aiming_angled", "running_angled_shoot":
					aimDirection = AimDirection.RIGHT_UP if not horizontalFlip else AimDirection.LEFT_UP
					bulletSpawnPoint.position = Vector2(-8.0, -13.0) if horizontalFlip else Vector2(8.0, -13.0)
				"aiming_down", "running_down_shoot":
					aimDirection = AimDirection.RIGHT_DOWN if not horizontalFlip else AimDirection.LEFT_DOWN
					bulletSpawnPoint.position = Vector2(-12.0, 3.0) if horizontalFlip else Vector2(12.0, 3.0)
		StateTypes.SWIMMING:
			match currentUpperBodyAnimation:
				"in_water_shoot":
					aimDirection = AimDirection.RIGHT if not horizontalFlip else AimDirection.LEFT
					bulletSpawnPoint.position = Vector2(-13.0, 5.5) if horizontalFlip else Vector2(13.0, 5.5)
				"in_water_up_shoot":
					aimDirection = AimDirection.UP
					bulletSpawnPoint.position = Vector2(-6.0, -16.0) if horizontalFlip else Vector2(4.5, -16.0)
				"in_water_angled_shoot":
					aimDirection = AimDirection.RIGHT_UP if not horizontalFlip else AimDirection.LEFT_UP
					bulletSpawnPoint.position = Vector2(-12.0, -5.0) if horizontalFlip else Vector2(10.0, -5.0)
		StateTypes.CROUCHING:
			bulletSpawnPoint.position = Vector2(-15.0, 10.5) if horizontalFlip else Vector2(15.0, 10.5)
			aimDirection = AimDirection.RIGHT if not horizontalFlip else AimDirection.LEFT
		StateTypes.JUMPING, StateTypes.FALLING:
			if Input.is_action_pressed("gp_up"):
				if Input.is_action_pressed("gp_moveRight"):
					aimDirection = AimDirection.RIGHT_UP
					bulletSpawnPoint.position = Vector2(10.0, -2.0)
				elif Input.is_action_pressed("gp_moveLeft"):
					aimDirection = AimDirection.LEFT_UP
					bulletSpawnPoint.position = Vector2(-10.0, -2.0)
				else:
					aimDirection = AimDirection.UP
					bulletSpawnPoint.position = Vector2(0.0, -5.0)
			elif Input.is_action_pressed("gp_crouch"):
				if Input.is_action_pressed("gp_moveRight"):
					aimDirection = AimDirection.RIGHT_DOWN
					bulletSpawnPoint.position = Vector2(10.0, 17.0)
				elif Input.is_action_pressed("gp_moveLeft"):
					aimDirection = AimDirection.LEFT_DOWN
					bulletSpawnPoint.position = Vector2(-10.0, 17.0)
				else:
					aimDirection = AimDirection.DOWN
					bulletSpawnPoint.position = Vector2(0.0, 22.0)
			else:
				aimDirection = AimDirection.RIGHT if not horizontalFlip else AimDirection.LEFT
				bulletSpawnPoint.position = Vector2(-11.0, 8.0) if horizontalFlip else Vector2(11.0, 8.0)
		_:
			pass
	
func _physics_process(delta):
	if inputAllowed:
		var RESULT = move_and_slide(Helper.RoundVector(playerVelocity), Vector2.UP)
		
	CheckCurrentPlatform()
	CheckShore()
	HandleShooting()
	
	#print(IsOnSurface(WorldAreas.PLATFORMS))
	
	PrintDebugInfo()
	
	if Input.is_key_pressed(KEY_1):
		if currentWeapon != WeaponType.STANDARD:
			currentWeapon = WeaponType.STANDARD
	elif Input.is_key_pressed(KEY_2):
		if currentWeapon != WeaponType.MACHINE_GUN:
			currentWeapon = WeaponType.MACHINE_GUN
	elif Input.is_key_pressed(KEY_3):
		if currentWeapon != WeaponType.SPREAD_GUN:
			currentWeapon = WeaponType.SPREAD_GUN
	elif Input.is_key_pressed(KEY_4):
		if currentWeapon != WeaponType.FLAMETHROWER:
			currentWeapon = WeaponType.FLAMETHROWER
	elif Input.is_key_pressed(KEY_5):
		if currentWeapon != WeaponType.LASER:
			currentWeapon = WeaponType.LASER
			
	if Input.is_key_pressed(KEY_P):
		#pause_mode = PAUSE_MODE_PROCESS
		get_tree().paused = not get_tree().paused
		

func HandleShooting() -> void:
	if not inputAllowed:
		return
	
	if bulletLimitMap[currentWeapon] == true:
		if not currentWeapon == WeaponType.LASER:
			return
			
	if fsm.CurrentStateIs(StateTypes.SWIMMING):
		if Input.is_action_pressed("gp_crouch") and not Input.is_action_pressed("gp_up"):
			return
	
	if Input.is_action_just_pressed("gp_fire"):
		if Helper.Equal($FireRateTimer.time_left, 0.0):
			Shoot()		
		else:
			if currentWeapon == WeaponType.LASER:
				Shoot()
	elif Input.is_action_pressed("gp_fire"):
		if Helper.Equal($FireRateTimer.time_left, 0.0):
			if currentWeapon == WeaponType.MACHINE_GUN:
				Shoot()
			elif currentWeapon == WeaponType.LASER:
				if bulletCountMap[WeaponType.LASER] == 0:
					Shoot()

func Shoot() -> void:
	UpdateShootingAnimation()
	UpdateAimDirectionAndBulletSpawnPosition()

	$FireRateTimer.wait_time = GlobalConstants.weaponsFireRateMap[currentWeapon]
	$FireRateTimer.start()
	
	var angleVector = GlobalConstants.angleEnumToVectorEnum[aimDirection]
	
	if currentWeapon == WeaponType.SPREAD_GUN:
		var shotsCount = bulletCountMap[WeaponType.SPREAD_GUN]
		var maxShotsCount = GlobalConstants.bulletsMaxCountMap[WeaponType.SPREAD_GUN]

		if shotsCount < maxShotsCount:
			for i in range(maxShotsCount - shotsCount):
				var spreadShotVector = Vector2.ZERO
				match i:
					0: spreadShotVector = angleVector
					1: spreadShotVector = angleVector.rotated(deg2rad(-10.0))
					2: spreadShotVector = angleVector.rotated(deg2rad(10.0))
					3: spreadShotVector = angleVector.rotated(deg2rad(-20.0))
					4: spreadShotVector = angleVector.rotated(deg2rad(20.0))
					_: return
				
				SpawnBullet(currentWeapon, self, spreadShotVector)
				
	elif currentWeapon == WeaponType.LASER:
		staticSpawner = bulletSpawnPoint.global_position
		
		if not fsm.CurrentStateIs(StateTypes.JUMPING) and not fsm.CurrentStateIs(StateTypes.FALLING):
			if aimDirection == AimDirection.RIGHT or aimDirection == AimDirection.LEFT: 
				staticSpawner.y += 1
				staticSpawner.x += 1 * (1 if horizontalFlip else -1)
		
		DestroyBullets(WeaponType.LASER)
		
		if Helper.IsAngledDirection(aimDirection):
			$FireRateTimer.wait_time /= 1.5
		
		SpawnBullet(WeaponType.LASER, self, angleVector, staticSpawner)
		yield($FireRateTimer, "timeout")
		$FireRateTimer.start()
			
		if bulletCountMap[WeaponType.LASER] == 1:
			SpawnBullet(WeaponType.LASER, self, angleVector, staticSpawner)
			yield($FireRateTimer, "timeout")
			$FireRateTimer.start()
			
			if bulletCountMap[WeaponType.LASER] == 2:
				SpawnBullet(WeaponType.LASER, self, angleVector, staticSpawner)
				yield($FireRateTimer, "timeout")
				$FireRateTimer.start()
				
				if bulletCountMap[WeaponType.LASER] == 3:
					SpawnBullet(WeaponType.LASER, self, angleVector, staticSpawner)
	else:
		SpawnBullet(currentWeapon, self, angleVector)
	
	#print(currentUpperBodyAnimation + " " + AimDirection.ToString(aimDirection))

func SpawnBullet(weaponType, playerObj, angleVector, _staticSpawner = null) -> KinematicBody2D:
	var bullet = load("res://Scenes/Bullet.tscn").instance().Init(weaponType, playerObj, angleVector)
	currentLevel.find_node("BulletsContainers").get_child(playerIdx).get_child(currentWeapon).add_child(bullet)
	bullet.global_position = _staticSpawner if _staticSpawner != null else bulletSpawnPoint.global_position
	
	return bullet
	
func DestroyBullets(weaponType : int) -> void:
	for bullet in currentLevel.find_node("BulletsContainers").get_child(playerIdx).get_child(weaponType).get_children():
		bullet.queue_free()

func UpdateShootingAnimation():
	match fsm.GetCurrentState().GetType():
		StateTypes.IDLE:
			if Input.is_action_pressed("gp_up"):
				ac.EmitAnimationChangeSignal(BodyPart.UPPER, "aiming_up_shoot", true)
			else:
				ac.EmitAnimationChangeSignal(BodyPart.UPPER, "idle_shoot", true)
		StateTypes.RUNNING:
			if Input.is_action_pressed("gp_up"):
				ac.EmitAnimationChangeSignal(BodyPart.UPPER, "running_angled_shoot", true)
			elif Input.is_action_pressed("gp_crouch"):
				ac.EmitAnimationChangeSignal(BodyPart.UPPER, "running_down_shoot", true)
			else:
				ac.EmitAnimationChangeSignal(BodyPart.UPPER, "running_shoot", true)
		StateTypes.CROUCHING:
			ac.EmitAnimationChangeSignal(BodyPart.FULL, "crouching_shoot", true)
		StateTypes.SWIMMING:
			if Helper.BothVerticalDirectionsPressed():
				ac.EmitAnimationChangeSignal(BodyPart.UPPER, "in_water_shoot", true)
				return
			
			if Input.is_action_pressed("gp_up"):
				if Helper.AnyHorizontalDirectionPressed():
					ac.EmitAnimationChangeSignal(BodyPart.UPPER, "in_water_angled_shoot", true)
				else:
					ac.EmitAnimationChangeSignal(BodyPart.UPPER, "in_water_up_shoot", true)
			else:
				ac.EmitAnimationChangeSignal(BodyPart.UPPER, "in_water_shoot", true)
		
func ConnectSignals() -> void:
	var RESULT
	RESULT = EventBus.connect("X_VELOCITY_CHANGED", 		   	self, "OnXVelocityChanged", 			[])
	RESULT = EventBus.connect("Y_VELOCITY_CHANGED", 		   	self, "OnYVelocityChanged", 			[])
	RESULT = EventBus.connect("PLAYER_BODY_ANIMATION_CHANGED", 	self, "OnPlayerBodyAnimationChanged", 	[])
	RESULT = EventBus.connect("PLAYER_BODY_H_FLIP_CHANGED", 	self, "OnBodyFlipChanged", 				[])
	RESULT = EventBus.connect("BULLETS_LIMIT_REACHED", 			self, "OnBulletsLimitReached", 			[])
	RESULT = EventBus.connect("BULLETS_COUNT_CHANGED",			self, "OnBulletsCountChanged", 			[])
	
func OnXVelocityChanged(newValue : float) -> void:
	if inputAllowed:
		playerVelocity.x = newValue
	
		# Handle the body flip to stop moving in correct orientation
		if newValue == 0 or Helper.BothHorizontalDirectionsPressed():
			return

func OnYVelocityChanged(newValue : float) -> void:
	if inputAllowed:
		playerVelocity.y = newValue

func OnPlayerBodyAnimationChanged(bodyPart : int, animationName : String, forced : bool) -> void:
	var body = null
	
	match bodyPart:
		BodyPart.NONE:
			return
		BodyPart.UPPER:
			body = $Body/UpperBody
		BodyPart.LOWER:
			body = $Body/LowerBody
		BodyPart.FULL:
			body = $Body/FullBody
			
	if bodyPart == BodyPart.FULL:
		$Body/UpperBody.visible = false
		# To exclude flickering upper idle animation when diving
		#EventBus.emit_signal("PLAYER_BODY_ANIMATION_CHANGED", BodyPart.UPPER, "none")
		$Body/LowerBody.visible = false
	else:
		$Body/FullBody.visible = false
	
	body.visible = true
	body.get_child(0).play(animationName)
	
	if bodyPart == BodyPart.UPPER:
		#UpdateAimDirectionAndBulletSpawnPosition()
		currentUpperBodyAnimation = animationName
		
func OnBodyFlipChanged(value : bool) -> void:
	if horizontalFlip != value:
		horizontalFlip = value

	for bodyPart in $Body.get_children():
		if bodyPart.flip_h != horizontalFlip:
			bodyPart.flip_h = horizontalFlip
	
func OnBulletsLimitReached(reached, weaponType, playerIndex) -> void:
	if playerIndex != playerIdx:
		return
		
	bulletLimitMap[weaponType] = reached

func OnBulletsCountChanged(count : int, weaponType : int, _playerIdx : int) -> void:
	if _playerIdx != playerIdx:
		print(str(_playerIdx) + " != " + str(playerIdx))
		return
		
	bulletCountMap[weaponType] = count
	
	#if currentWeapon == WeaponType.LASER and Input.is_action_pressed("gp_fire"):
	#	if Helper.Equal($FireRateTimer.time_left, 0.0):
	#		Shoot()
	
	print(WeaponType.ToString(currentWeapon) + " " + str(bulletCountMap[weaponType]))
	
func SetIsPlayerTwo(value : bool) -> void:
	$Body/UpperBody.get_material().set_shader_param("is_player_two", value)
	$Body/LowerBody.get_material().set_shader_param("is_player_two", value)
	$Body/FullBody.get_material().set_shader_param("is_player_two", value)

func PrintDebugInfo():	
	if Input.is_action_just_pressed("ui_debug"):
		debugInfo.visible = not debugInfo.visible
		
	var currentState = fsm.GetCurrentState()
	if currentState != null:
		debugInfo.SetStateString(currentState.GetStateName())
	else:
		debugInfo.SetStateString('null')
		
	debugInfo.SetDirectionString(playerVelocity)
	
func IsOnSurface(surface : int) -> bool:
	var retValue = false
	
	match surface:
		WorldAreas.PLATFORMS:
			return Helper.IsObjectHitLayer(self, $FeetBox.global_position, GlobalConstants.LAYER_PLATFORMS_MASK_BIT)
		WorldAreas.WATER:
			return Helper.IsObjectHitLayer(self, $FeetBox.global_position + Vector2(0.0, 4.0), GlobalConstants.LAYER_WATER_MASK_BIT)
		WorldAreas.KILLBOX:
			return Helper.IsObjectHitLayer(self, $FeetBox.global_position, GlobalConstants.LAYER_KILLBOX_MASK_BIT)
			
	return retValue

func CheckShore() -> void:
	var ray = $Rays/ClosestSurfaceChecker
	if IsOnSurface(WorldAreas.WATER) and fsm.CurrentStateIs(StateTypes.SWIMMING):
		if not ray.enabled:
			ray.enabled = true
			
		if ray.is_colliding():
			fsm.currentState.TransitionTo(StateTypes.CLIMBING)
	else:
		if ray.enabled:
			ray.enabled = false

func CheckCurrentPlatform() -> void:
	yield(get_tree().root, "ready")
	
	if not fsm.CurrentStateIs(StateTypes.SWIMMING):
		for groundChecker in $Rays/GroundCheckers.get_children():
			if groundChecker.is_colliding():
				var collider = groundChecker.get_collider()
				var colliderShapeIdx = groundChecker.get_collider_shape()
				if lastCollisionShapeIdx != colliderShapeIdx:
					lastCollisionShapeIdx = colliderShapeIdx
					currentPlatformCollider = collider
					isOnOneWayPlatform = collider.get_child(colliderShapeIdx).one_way_collision
					return
			
func GetClosestSurfaceName() -> String:
	var surfaceName = ""
	if $Rays/ClosestSurfaceChecker.is_colliding():
		surfaceName = $Rays/ClosestSurfaceChecker.get_collider().name
		
	return surfaceName

func AdjustPosition(newPosition : Vector2) -> void:
	set_position(position + newPosition)

func AdvanceXPosition(value : float) -> void:
	position.x += value * (-1.0 if horizontalFlip else 1.0)

func ToggleInputAllowed() -> void:
	inputAllowed = not inputAllowed

func SetInputAllowed(value : bool) -> void:
	inputAllowed = value

func SetCollisionMaskBitEnabled(layer : int, value : bool) -> void:
	set_collision_mask_bit(layer, value)
	
func SetCollisionLayerBitEnabled(layer : int, value : bool) -> void:
	set_collision_layer_bit(layer, value)
