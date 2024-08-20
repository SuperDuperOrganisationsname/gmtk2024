extends Control

signal pause_menu_reset_level
signal pause_menu_open_controls
signal skip_level

var pause_menu_active = false

@onready var reset_counter: Label = $ColorRect/VBoxContainer/ResetCounter

func toggle_pause_menu() -> void:
	pause_menu_active = !pause_menu_active
	get_tree().paused = pause_menu_active
	visible = pause_menu_active  

func _ready() -> void:
	reset_counter.text = "Resets: 0"
	visible = pause_menu_active

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("open_pause_menu"):
		toggle_pause_menu()

func _on_player_toggle_pause_menu() -> void:
	toggle_pause_menu()

func _on_continue_button_pressed() -> void:
	toggle_pause_menu()

func _on_reset_button_pressed() -> void:
	toggle_pause_menu()
	pause_menu_reset_level.emit()

func _on_controls_button_pressed() -> void:
	pause_menu_open_controls.emit()

func _on_quit_button_pressed() -> void:
	toggle_pause_menu()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn") 


func _on_game_num_resets_signal(resets: int) -> void:
	reset_counter.text = "Resets: " + str(resets)


func _on_skip_level_button_pressed() -> void:
	skip_level.emit()

func _on_game_level_skipped() -> void:
	toggle_pause_menu()	
