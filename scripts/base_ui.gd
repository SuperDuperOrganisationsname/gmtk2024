extends Control

enum ScaleMode {
	MIDDLE,
	RIGHT,
	LEFT
}

var heart_frames = [3,2,6,10]

@export var scale_mode: ScaleMode = ScaleMode.MIDDLE

@onready var scale_mode_logo: Sprite2D = $ScaleModeLogo

func _process(delta: float) -> void:
	match scale_mode:
		ScaleMode.MIDDLE:
			scale_mode_logo.frame = 1
		ScaleMode.RIGHT:
			scale_mode_logo.frame = 3
		ScaleMode.LEFT:
			scale_mode_logo.frame = 5

func _on_ui_change_scale_type(i: int) -> void:
	if i == -1:
		scale_mode = ScaleMode.LEFT
	elif i == 1:
		scale_mode = ScaleMode.RIGHT
	else:
		scale_mode = ScaleMode.MIDDLE

func _update_int_scale(scale: float) -> void:
	$Scale.text = str(scale).pad_decimals(1)


func _update_int_size(size: int) -> void:
	$Interval.text = str(size)


func _on_ui_change_health(i:int) -> void:
	return
	

func _update_current_level(level: int) -> void:
	$CurrentLevel.text = str(level)
