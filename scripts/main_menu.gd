extends Control

signal change_scene(name: String)

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/intro_cutscene.tscn") 

func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits_menu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
