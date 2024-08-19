extends Control

var pause_controls_active = false

func _ready() -> void:
    visible = pause_controls_active
    
func toggle_controls_menu() -> void:
    pause_controls_active = !pause_controls_active
    visible = pause_controls_active 

func _on_close_button_pressed() -> void:
    toggle_controls_menu()
