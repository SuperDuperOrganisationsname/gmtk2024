extends CanvasLayer

signal change_scale_type(int)
signal change_health(i: int)

signal int_scale(scale: float)
signal int_size(size: int)

signal current_level(level: int)

signal num_resets(resets: int)
signal total_time(time: int)
signal level_time(time: int)

func _on_scaling_tilemap_change_scale_type(i: int) -> void:
	change_scale_type.emit(i)


func _get_int_scale(scale: float) -> void:
	int_scale.emit(scale)


func _get_int_size(size: int) -> void:
	int_size.emit(size)


func _on_player_player_hit(cur_health:int) -> void:
	change_health.emit(cur_health)

func _update_level(level: int) -> void:
	current_level.emit(level)


func _on_game_level_time_signal(time: int) -> void:
	level_time.emit(time)


func _on_game_total_time_signal(time: int) -> void:
	total_time.emit(time)
