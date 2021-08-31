extends Node

class_name WorldAreas

enum{
	PLATFORMS = 0,
	WATER = 1,
	KILLBOX = 2
}

const StringTable = {
	PLATFORMS = "PLATFORMS",
	WATER = "WATER",
	KILLBOX = "KILLBOX"
}

static func ToString(area : int) -> String:
	if not StringTable.has(area):
		return 'Unknown state'
	else:
		return StringTable[area]
