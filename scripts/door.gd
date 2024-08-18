extends Node2D

signal complete_level

@export var keys: Array[Node2D] = []

var player_on_door: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var num_keys = process_keys()
	self.frame = num_keys
	if num_keys == 0 and player_on_door and Input.is_action_just_pressed("enter_door"):
		complete_level.emit()

func process_keys() -> int:
	var num_keys: int = 0
	for key in keys:
		if key.visible == true:
			num_keys += 1
		else:
			key.process_mode = Node.PROCESS_MODE_DISABLED
	
	return num_keys

func _on_door_entered(_body: Node2D) -> void:
	player_on_door = true


func _on_door_exited(_body: Node2D) -> void:
	player_on_door = false
