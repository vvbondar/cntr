extends Node

class_name AimDirection

enum {
	RIGHT,
	RIGHT_UP,
	RIGHT_DOWN,
	LEFT,
	LEFT_UP,
	LEFT_DOWN,
	UP,
	DOWN,
		
	NONE
}

const StringTable = {
	RIGHT 	 	: "RIGHT",
	RIGHT_UP 	: "RIGHT_UP",
	RIGHT_DOWN	: "RIGHT_DOWN",
	LEFT		: "LEFT",
	LEFT_UP		: "LEFT_UP",
	LEFT_DOWN	: "LEFT_DOWN",
	UP			: "UP",
	DOWN		: "DOWN",
		
	NONE		: "NONE",
}

static func ToString(state : int):
	if not StringTable.has(state):
		return 'Unknown state'
	else:
		return StringTable[state]
