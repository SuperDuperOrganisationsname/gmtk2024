extends Node2D

@export var levels: Array[Node2D] = []
@export var spawns: Array[Node2D] = []
@export var current_level: int = 0
@export var player: CharacterBody2D

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
	player.position = spawns[current_level].position
