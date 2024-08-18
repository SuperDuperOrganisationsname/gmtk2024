extends Node2D

func _on_player_entered(body: Node2D) -> void:
	self.visible = false
