class_name BodyPart

enum {
	UPPER,
	LOWER,
	FULL,
	NONE
}

const StringTable = {
	UPPER : "UPPER",
	LOWER : "LOWER",
	FULL : "FULL",
	NONE : "NONE"
}

static func ToString(state : int):
	if not StringTable.has(state):
		return 'Unknown state'
	else:
		return StringTable[state]
