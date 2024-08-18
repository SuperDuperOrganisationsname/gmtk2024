extends Node2D

@onready var up: RayCast2D = $UpRay
@onready var left: RayCast2D = $LeftRay
@onready var down: RayCast2D = $DownRay
@onready var right: RayCast2D = $RightRay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
