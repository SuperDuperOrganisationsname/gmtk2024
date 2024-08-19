extends Node2D

@export var pressed: bool = false

func _process(_delta: float) -> void:
	$Sprite.frame = pressed as int

func reset_button():
	pressed = false

func _on_area_2d_body_entered(_coll) -> void:
	pressed = true
