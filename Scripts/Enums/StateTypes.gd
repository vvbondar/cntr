class_name StateTypes

enum {
	NONE      = 0,
	IDLE      = 1,
	RUNNING   = 2,
	JUMPING   = 3,
	FALLING   = 4,
	CROUCHING = 5,
	SWIMMING  = 6,
	CLIMBING  = 7,
	
	RUNNING_ANGLED = 8
}

const StringTable = {
	NONE      : 'NONE',
	IDLE      : 'IDLE',
	RUNNING   : 'RUNNING',
	JUMPING   : 'JUMPING',
	FALLING   : 'FALLING',
	CROUCHING : "CROUCHING",
	SWIMMING  : "SWIMMING",
	CLIMBING  : "CLIMBING",
	
	RUNNING_ANGLED : "RUNNING_ANGLED"
}

static func ToString(state : int):
	if not StringTable.has(state):
		return 'Unknown state'
	else:
		return StringTable[state]
