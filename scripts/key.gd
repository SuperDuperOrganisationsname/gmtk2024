extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	animation_player.play("RESET")

func _on_player_entered(body: Node2D) -> void:
	animation_player.play("pickup_animation")
