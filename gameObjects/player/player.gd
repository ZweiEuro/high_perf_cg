extends Node3D


func getCurrentForwardDirection() -> Vector3:
	return	$"./PlayerBody".getDirection()
