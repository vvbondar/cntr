extends Node

class_name WeaponType

enum {
	STANDARD,
	MACHINE_GUN,
	SPREAD_GUN,
	FLAMETHROWER,
	LASER
}

const StringTable = {
	STANDARD 	: 'STANDARD',
	MACHINE_GUN	: 'MACHINE_GUN',
	SPREAD_GUN	: 'SPREAD_GUN',
	FLAMETHROWER: 'FLAMETHROWER',
	LASER   	: 'LASER'
}

static func ToString(state : int):
	if not StringTable.has(state):
		return 'Unknown weapon'
	else:
		return StringTable[state]
