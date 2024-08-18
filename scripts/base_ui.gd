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