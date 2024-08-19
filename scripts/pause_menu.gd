extends Control

var pause_menu_active = false

func _ready() -> void:
    visible = pause_menu_active

func _on_player_toggle_pause_menu() -> void:
    pause_menu_active = !pause_menu_active
    visible = pause_menu_active

func _on_continue_button_pressed() -> void:
    pass # Replace with function body.

func _on_reset_button_pressed() -> void:
    pass # Replace with function body.

func _on_controls_button_pressed() -> void:
    pass # Replace with function body.

func _on_quit_button_pressed() -> void:
    get_tree().quit()