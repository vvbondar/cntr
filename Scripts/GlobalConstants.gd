extends Node

var GRAVITY_FACTOR = 8

const JUMPFORCE = -235
const BASE_GRAVITY = 64
const PLAYER_HORIZONTAL_SPEED_WALKING = 60
const PLAYER_HORIZONTAL_SPEED_JUMPING_FROM_RUN = 59
const PLAYER_HORIZONTAL_SPEED_JUMPING_IN_AIR = 60
const PLAYER_HORIZONTAL_SPEED_FALLING_IN_AIR = 45
const PLAYER_HORIZONTAL_SPEED_FALLING_OFF_EDGE = 60 #55
const PLAYER_HORIZONTAL_SPEED_SWIMMING = 55

const LAYER_GENERAL_MASK_BIT = 0
const LAYER_PLATFORMS_MASK_BIT = 1
const LAYER_WATER_MASK_BIT = 2
const LAYER_KILLBOX_MASK_BIT = 3
const LAYER_PLAYER_BULLETS_MASK_BIT = 4

const LAYER_PLAYER_ONE = 5
const LAYER_PLAYER_TWO = 6


const BULLET_SPEED_PLAYER = 220

const invulnarabilityTimeout = 3.0

const bulletsMaxCountMap = {
	WeaponType.STANDARD 	: 4,
	WeaponType.MACHINE_GUN 	: 6,
	WeaponType.SPREAD_GUN 	: 10,
	WeaponType.FLAMETHROWER : 4,
	WeaponType.LASER 		: 4
}

const weaponsFireRateMap = {
	WeaponType.STANDARD 	: 0.1,
	WeaponType.MACHINE_GUN 	: 0.11,
	WeaponType.SPREAD_GUN 	: 0.16,
	WeaponType.FLAMETHROWER : 0.15,
	WeaponType.LASER 		: 0.052
}

const angleEnumToVectorEnum = {
	AimDirection.RIGHT 	  	: Vector2.RIGHT,
	AimDirection.RIGHT_UP	: Vector2(1.0, -1.0),
	AimDirection.RIGHT_DOWN : Vector2(1.0, 1.0),
	AimDirection.LEFT 		: Vector2.LEFT,
	AimDirection.LEFT_UP 	: Vector2(-1.0, -1.0),
	AimDirection.LEFT_DOWN 	: Vector2(-1.0, 1.0),
	AimDirection.UP 		: Vector2.UP,
	AimDirection.DOWN 		: Vector2.DOWN,
		
	AimDirection.NONE		: Vector2.ZERO
}

const angleVectorToEnum = {
	Vector2.RIGHT 	  	: AimDirection.RIGHT,
	Vector2(1.0, -1.0)	: AimDirection.RIGHT_UP,
	Vector2(1.0, 1.0) 	: AimDirection.RIGHT_DOWN,
	Vector2.LEFT 		: AimDirection.LEFT,
	Vector2(-1.0, -1.0) : AimDirection.LEFT_UP,
	Vector2(-1.0, 1.0) 	: AimDirection.LEFT_DOWN,
	Vector2.UP 			: AimDirection.UP,
	Vector2.DOWN 		: AimDirection.DOWN,
		
	Vector2.ZERO		: AimDirection.NONE
}
