extends Control

enum ScaleMode {
    MIDDLE,
    RIGHT,
    LEFT
}

@export var scale_mode: ScaleMode = ScaleMode.MIDDLE

@onready var scale_mode_logo: Sprite2D = $ScaleModeLogo

func _process(delta: float) -> void:
    match scale_mode:
        ScaleMode.MIDDLE:
            scale_mode_logo.frame = 3
        ScaleMode.RIGHT:
            scale_mode_logo.frame = 7
        ScaleMode.LEFT:
            scale_mode_logo.frame = 11

func _on_ui_change_scale_type(i: int) -> void:
    if i == -1:
        scale_mode = ScaleMode.LEFT
    elif i == 1:
        scale_mode = ScaleMode.RIGHT
    else:
        scale_mode = ScaleMode.MIDDLE