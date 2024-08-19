extends Node2D

@export var num_levels: int = 3
@export var player: CharacterBody2D
@export var current_level: int = 0
@export var level_placeholder: Node

var levels = []
var cur_level

var reset_next_frame: bool = false

signal player_reset_health
signal reset_scale

func _ready() -> void:
	level_placeholder.queue_free()
	
	for i in range(num_levels):
		levels.append(load_level_from_file(i + 1))
	
	load_level(levels[current_level])

func load_level_from_file(level: int) -> PackedScene:
	var path = "res://scenes/levels/level_{num}.tscn".format({"num": str(level)})
	return load(path)

func load_level(level):
	if cur_level:
		cur_level.queue_free()
	var instance = level.instantiate()
	instance.connect("level_completed", self._on_complete_level)
	self.add_child(instance)
	player.position = instance.spawn_position
	cur_level = instance

func reset_level():
	load_level(levels[current_level])
	player_reset_health.emit()
	reset_scale.emit()

func _on_complete_level() -> void:
	current_level += 1
	reset_level()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset_level"):
		reset_next_frame = true
	
	if reset_next_frame:
		reset_next_frame = false
		reset_level()

func _on_killzone_entered(body: Node2D) -> void:
	reset_next_frame = true
