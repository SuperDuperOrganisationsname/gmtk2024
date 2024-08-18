extends CanvasLayer

signal change_scale_type(int)

signal int_scale(scale: float)
signal int_size(size: int)

func _on_scaling_tilemap_change_scale_type(i: int) -> void:
	change_scale_type.emit(i)


func _get_int_scale(scale: float) -> void:
	int_scale.emit(scale)


func _get_int_size(size: int) -> void:
	int_size.emit(size)
