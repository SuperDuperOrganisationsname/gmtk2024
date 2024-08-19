extends Control

var controls_overlay_active = false

func _ready() -> void:
    visible = controls_overlay_active
    
func toggle_controls_menu() -> void:
    controls_overlay_active = !controls_overlay_active
    visible = controls_overlay_active 

func _on_close_button_pressed() -> void:
    toggle_controls_menu()

func _on_pause_menu_pause_menu_open_controls() -> void:
    controls_overlay_active = true
    visible = controls_overlay_active