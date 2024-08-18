extends Node2D

signal squished

@export var exception: CollisionObject2D
@export var RAY_LENGTH: int

@onready var up: RayCast2D = $UpRay
@onready var left: RayCast2D = $LeftRay
@onready var down: RayCast2D = $DownRay
@onready var right: RayCast2D = $RightRay


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	up.target_position = Vector2(0, -RAY_LENGTH)
	left.target_position = Vector2(-RAY_LENGTH, 0)
	down.target_position = Vector2(0, RAY_LENGTH)
	right.target_position = Vector2(RAY_LENGTH, 0)
	
	up.add_exception(exception)
	left.add_exception(exception)
	down.add_exception(exception)
	right.add_exception(exception)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !left.is_colliding() or !right.is_colliding():
		return
	if !up.is_colliding() or !down.is_colliding():
		return
		
	squished.emit()
