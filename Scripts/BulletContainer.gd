extends Node2D

export var playerIdx : int = -1

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

const BULLET_SCENE = preload("res://Scenes/Bullet.tscn")

onready var playersContainer = get_node("../../Players")
var laserShotInProgress : bool = false

func Init(_playerIdx : int) -> Object:
	playerIdx = _playerIdx
	print_debug("Bullet container for Player" + str("One" if playerIdx == 0 else "Two") + " initialized")
	return self

#func _ready():
#	for i in range(playersContainer.get_child_count()):
#		if get_parent().get_child(i) == self:
#			if playersContainer.get_child(i) != null:
#				playerIdx = i
#				print_debug("Bullet container for Player" + str("One" if playerIdx == 0 else "Two") + " initialized")
				
	#var RESULT = EventBus.connect("LASER_FIRED", self, "OnLaserFired", [])
	
func OnLaserFired(_playerIdx : int, angle : Vector2, spawnPoint : Vector2) -> void:
	for laserBeam in get_child(WeaponType.LASER).get_children():
		#laserBeam.global_position = spawnPoint
		laserBeam.queue_free()
	
	if laserShotInProgress:
		return
		
	laserShotInProgress = true
	
	for i in range(GlobalConstants.bulletsMaxCountMap[WeaponType.LASER]):
		var bullet = BULLET_SCENE.instance().Init(WeaponType.LASER, playersContainer.get_child(playerIdx), angle)
		get_child(WeaponType.LASER).add_child(bullet)
		bullet.global_position = spawnPoint
		
		yield(get_tree().create_timer(GlobalConstants.weaponsFireRateMap[WeaponType.LASER]), "timeout")

	laserShotInProgress = false
	
func _physics_process(_delta):
	for i in range(get_child_count()):
		var reached = false
		
		if i == WeaponType.LASER:
			reached = get_child(i).get_child_count() > 0
		else:
			reached = get_child(i).get_child_count() >= GlobalConstants.bulletsMaxCountMap[i]
					
		if bulletLimitMap[i] != reached:
			bulletLimitMap[i] = reached
			EventBus.emit_signal("BULLETS_LIMIT_REACHED", reached, i, playerIdx)
	
	
	for i in range(get_child_count()):
		if bulletCountMap[i] != get_child(i).get_child_count() and get_child(i).get_child_count() <= GlobalConstants.bulletsMaxCountMap[i]:
			bulletCountMap[i] = get_child(i).get_child_count()
			EventBus.emit_signal("BULLETS_COUNT_CHANGED", bulletCountMap[i], i, playerIdx)
