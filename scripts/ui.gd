extends CanvasLayer

signal change_scale_type(int)


func _on_scaling_tilemap_change_scale_type(i: int) -> void:
	change_scale_type.emit(i)
