extends Node2D

signal complete_level

@export var teleport: Vector2i = Vector2i(0, 0)
@export var num_keys: int = 0

var player_on_door: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.frame = num_keys
	if num_keys == 0 and player_on_door and Input.is_action_just_pressed("enter_door"):
		complete_level.emit()


func _on_door_entered(_body: Node2D) -> void:
	player_on_door = true


func _on_door_exited(_body: Node2D) -> void:
	player_on_door = false
