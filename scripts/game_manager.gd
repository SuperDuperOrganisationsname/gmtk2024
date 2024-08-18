extends Node2D

@export var levels: Array[Node2D] = []
@export var current_level: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#for level in levels:
		#level.process_mode = Node.PROCESS_MODE_DISABLED
		#level.visible = false
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for i in levels.size():
		if i == current_level: 
			levels[i].process_mode = Node.PROCESS_MODE_INHERIT
			levels[i].visible = true
		else:
			levels[i].process_mode = Node.PROCESS_MODE_DISABLED
			levels[i].visible = false
		


func _on_complete_level() -> void:
	current_level += 1
