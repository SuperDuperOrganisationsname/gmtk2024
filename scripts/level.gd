extends Node2D

@export var spawn_position: Vector2i = Vector2i(0, 0)

signal level_completed

func _on_door_enter():
	level_completed.emit()
