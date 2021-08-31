extends Camera2D

#var startX
#var startY = 64

#func _ready():
#	startX = $LeftWall.global_position.x

# Cheesy shit to play around zoom factor
#func _process(delta):
#	var offset = -get_canvas_transform()[2].x + 244
#	$LeftWall.global_position = Vector2(startX + offset * get_zoom().x, startY)
#	$RightWall.global_position = Vector2(startX + offset * get_zoom().x + 314, startY)
