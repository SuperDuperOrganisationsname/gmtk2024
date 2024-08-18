extends RigidBody2D

signal return_me

var new_position: Vector2 = Vector2(0, 0)
var update_position: bool = false

var is_flying: bool = false
var should_freeze: bool = false

var squish_counter: int = 0
var floor_counter: int = 0

func _integrate_forces(state) -> void:
	if update_position:
		state.transform = Transform2D(0.0, new_position)
		update_position = false
	
	if is_flying and self.linear_velocity == Vector2(0, 0) and floor_counter >= 10:
		is_flying = false
		var pos = state.transform.get_origin() as Vector2i
		if pos.x < 0:
			pos.x -= 16
		pos.x = pos.x / 16 as int * 16 + 8
		
		state.transform = Transform2D(0.0, pos)
		should_freeze = true	
		floor_counter = 0

func _process(_delta: float) -> void:
	if should_freeze:
		self.freeze = true
		should_freeze = false
	if $FloorCheck.is_colliding():
		floor_counter += 1
	elif is_flying and self.linear_velocity == Vector2(0, 0):
		self.linear_velocity = Vector2(0, 0.01)

func _on_squished() -> void:
	squish_counter += 1
	if squish_counter == 10:
		return_me.emit()
		squish_counter = 0
