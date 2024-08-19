extends Node2D

@export var buttons: Array[Node2D] = []
@export var key: Node2D

var key_pos: Vector2

func _ready() -> void:
	key.process_mode = Node.PROCESS_MODE_DISABLED
	key_pos = key.position
	key.position.y = 10000

func reset():
	for button in buttons:
		button.reset()

func is_finished() -> bool:
	for button in buttons:
		if !button.pressed:
			return false
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_finished():
		key.process_mode = Node.PROCESS_MODE_INHERIT
		key.position = key_pos
		$Sprite.frame = 0
	else:
		key.process_mode = Node.PROCESS_MODE_DISABLED
		key.position.y = 10000
		$Sprite.frame = 1
