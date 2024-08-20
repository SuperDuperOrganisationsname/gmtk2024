extends Control

signal pause_menu_reset_level
signal pause_menu_open_controls
signal skip_level

var pause_menu_active = false

@onready var reset_counter: Label = $ColorRect/VBoxContainer/ResetCounter

@onready var continue_button: Button = $ColorRect/VBoxContainer/ContinueButton
@onready var reset_button: Button = $ColorRect/VBoxContainer/ResetButton
@onready var skip_level_button: Button = $ColorRect/VBoxContainer/SkipLevelButton
@onready var controls_button: Button = $ColorRect/VBoxContainer/ControlsButton
@onready var quit_button: Button = $ColorRect/VBoxContainer/QuitButton

@onready var active_button = 0
var focused_button = null

func select_next_button(i_offset: int) -> void:
	if active_button + i_offset < 0:
		active_button = 4
	elif active_button + i_offset > 4:
		active_button = 0
	else:
		active_button += i_offset
	
	if active_button == 0:
		focused_button = continue_button
	elif active_button == 1:
		focused_button = reset_button
	elif active_button == 2:
		focused_button = skip_level_button
	elif active_button == 3:
		focused_button = controls_button
	elif active_button == 4:
		focused_button = quit_button

	focused_button.grab_focus()
	

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
	
	if Input.is_action_just_pressed("down") or Input.is_action_just_pressed("ui_down"):
		select_next_button(1)

	if Input.is_action_just_pressed("enter_door") or Input.is_action_just_pressed("ui_up"):
		select_next_button(-1)

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
