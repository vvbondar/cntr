extends Node2D

export var multiplayerEnabled : bool = false

const PLAYER_SCENE = preload("res://Scenes/Characters/Player.tscn")

#var playerOne : KinematicBody2D = null

#var playerOneBullets : Array = []
#onready var playerOne : KinematicBody2D = $Players.get_child(0)
#onready var playerTwo : KinematicBody2D = $Players.get_child(1)

class PlayersPositionSorter:
	static func SortByPositionX(prevPlayer : KinematicBody2D, nextPlayer : KinematicBody2D) -> bool:
		return prevPlayer.position.x < nextPlayer.position.x

func _ready():
	var playerOne = load("res://Scenes/Characters/Player.tscn").instance().Init(true)
	$Players.add_child(playerOne)
	playerOne.position = $Camera2D.position + Vector2(-81.0, -86.0) #Vector2(-81.0, -86.0)
	
	var playerOneBulletContainer = load("res://Scenes/BulletContainer.tscn").instance().Init(0)
	$BulletsContainers.add_child(playerOneBulletContainer)
	
	if not multiplayerEnabled:
		return
	
	var playerTwo = load("res://Scenes/Characters/Player.tscn").instance().Init(false)
	$Players.add_child(playerTwo)
	playerTwo.position = $Camera2D.position + Vector2(-32.0, -86.0)
	
	var playerTwoBulletContainer = load("res://Scenes/BulletContainer.tscn").instance().Init(1)
	$BulletsContainers.add_child(playerTwoBulletContainer)

func _process(_delta : float):
	UpdateCameraPosition()

#	UpdateBulletsCount()
	#TileMap.
	#print($BulletsContainers/P1Bullets.get_child(1).get_child_count())
	

func UpdateCameraPosition():
	var players = $Players.get_children()
	players.sort_custom(PlayersPositionSorter, "SortByPositionX")
	
	if players[0].position.x > $Camera2D.position.x:
		$Camera2D.position.x = players[0].position.x

