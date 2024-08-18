extends RigidBody2D

var new_position: Vector2 = Vector2(0, 0)
var update_position: bool = false

var is_flying: bool = false

func _integrate_forces(state) -> void:
	if update_position:
		state.transform = Transform2D(0.0, new_position)
		update_position = false
	
	if is_flying and self.linear_velocity == Vector2(0, 0) and $FloorCheck.is_colliding():
		is_flying = false
		var pos = state.transform.get_origin() as Vector2i
		if pos.x < 0:
			pos.x -= 16
		pos.x = pos.x / 16 as int * 16 + 8
		
		
		state.transform = Transform2D(0.0, pos)
		self.freeze = true	

func _process(delta: float) -> void:
	pass
