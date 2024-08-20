extends Control

signal change_scene(name: String)

@onready var click_sound: AudioStreamPlayer2D = $ClickSound

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("open_pause_menu"):
		self._on_quit_button_pressed()
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		self._on_start_button_pressed()
	if Input.is_action_just_pressed("attack"):
		self._on_credits_button_pressed()	

func _on_start_button_pressed() -> void:
	click_sound.play()	
	get_tree().change_scene_to_file("res://scenes/intro_cutscene.tscn") 

func _on_credits_button_pressed() -> void:
	click_sound.play()
	get_tree().change_scene_to_file("res://scenes/credits_menu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
