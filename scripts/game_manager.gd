extends Node2D

@export var num_levels: int = 20
@export var player: CharacterBody2D
@export var current_level: int = 0
@export var level_placeholder: Node
@export var num_resets = 0

var levels = []
var cur_level

var reset_next_frame: bool = false

signal player_reset_health
signal reset_scale
signal signal_cur_level(level: int)
signal num_resets_signal(resets: int)
signal level_skipped
signal total_time_signal(time: int)
signal level_time_signal(time: int)

var start_time: int = 0
var level_start_time: int = 0

@onready var key_pickup_sound: AudioStreamPlayer = $KeyPickupSound
@onready var door_sound: AudioStreamPlayer = $DoorSound

func _ready() -> void:
	level_placeholder.queue_free()
	
	for i in range(num_levels):
		levels.append(load_level_from_file(i + 1))
	
	load_level(levels[current_level])
	start_time = Time.get_ticks_msec()
	level_start_time = Time.get_ticks_msec()

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
	signal_cur_level.emit(current_level + 1)

func reset_level():
	player_reset_health.emit()
	reset_scale.emit()
	load_level(levels[current_level])
	num_resets += 1
	level_start_time = Time.get_ticks_msec()

func _on_complete_level() -> void:
	if !door_sound.playing:
		door_sound.play()
	current_level += 1
	reset_level()
	num_resets -= 1

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset_level"):
		reset_next_frame = true
	
	if reset_next_frame:
		reset_next_frame = false
		reset_level()
	num_resets_signal.emit(num_resets)
	
	total_time_signal.emit(Time.get_ticks_msec() - start_time)
	level_time_signal.emit(Time.get_ticks_msec() - level_start_time)

func _on_killzone_entered(body: Node2D) -> void:
	reset_next_frame = true


func _on_pause_menu_pause_menu_reset_level() -> void:
	reset_level()


func _skip_level():
	if current_level < num_levels - 1:
		current_level += 1
		reset_level()
		num_resets -= 1
		level_skipped.emit()


func _on_pause_menu_skip_level() -> void:
	self._skip_level()