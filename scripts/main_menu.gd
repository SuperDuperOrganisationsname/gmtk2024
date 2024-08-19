extends Control

signal change_scene(name: String)

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn") 

func _on_credits_button_pressed() -> void:
	pass # Replace with function body.

func _on_quit_button_pressed() -> void:
	get_tree().quit()
