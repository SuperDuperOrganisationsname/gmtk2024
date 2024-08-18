extends RigidBody2D

var new_position: Vector2 = Vector2(0, 0)
var update_position: bool = false

func _integrate_forces(state) -> void:
	if update_position:
		state.transform = Transform2D(0.0, new_position)
		update_position = false
		
