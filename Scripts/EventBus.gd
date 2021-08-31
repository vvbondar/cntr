# Event bus for distant nodes to communicate using signals.
# This is intended for cases where connecting the nodes directly creates more coupling
# or increases code complexity substantially.
extends Node

# Emitted when state from FSM list is changed
signal STATE_CHANGED(newState)
signal X_VELOCITY_CHANGED(newValue)
signal Y_VELOCITY_CHANGED(newValue)

signal PLAYER_BODY_ANIMATION_CHANGED(bodyPart, animationName, forced)
signal PLAYER_BODY_H_FLIP_CHANGED(value)
signal PLAYER_AIM_DIRECTION_CHANGED(newDirection)

signal BULLETS_LIMIT_REACHED(reached, weaponType, playerIdx)
signal BULLETS_COUNT_CHANGED(count, weaponType, playerIdx)

signal LASER_FIRED(playerIdx, angle, spawnPoint)
