extends CharacterBody2D

signal throw_talisman(vector: Vector2)

const SPEED = 130.0
const JUMP_VELOCITY = -300.0 
const INDICATOR_DISTANCE = 18
const INDICATOR_ROTATION_SPEED = 0.2
const INDICATOR_ROTATION_CENTER = Vector2(0, -17)

var direction = 1
var last_direction = 1
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var indicator_rotation = 0

# checks if the last frame was in the air, to detect when you land
var last_frame_in_air = false

@export_group("Timers")
## Time in seconds that a jump ist still performed after press
@export var jump_buffer_time: float = 0.1
## Time in seconds that the player can still jump after leaving the ground
@export var coyote_time: float = 0.1

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var throw_indicator: StaticBody2D = $ThrowIndicator
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var input_buffer: Timer = $InputBuffer

func _ready() -> void:
	animation_tree.active = true
	throw_indicator.visible = false
	
func _process(delta: float) -> void:
	update_animation()
	last_frame_in_air = not is_on_floor()

func _physics_process(delta):
	var throw_pressed = Input.is_action_pressed("throw")
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		coyote_timer.start(coyote_time)	
		velocity.y = 0	
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and coyote_timer.time_left > 0:
		coyote_timer.stop()
		velocity.y = JUMP_VELOCITY
		
	direction = Input.get_axis("move_left", "move_right")
	var rotation_direction = direction
	# left -1, right +1
	if direction and not throw_pressed:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Throw indicator
	# Setup throw indicator
	if Input.is_action_just_pressed("throw"):
		if last_direction == -1:
			throw_indicator.rotation = PI
			indicator_rotation = PI
		else:
			throw_indicator.rotation = 0
			indicator_rotation = 0
		throw_indicator.position.x = last_direction * INDICATOR_DISTANCE + INDICATOR_ROTATION_CENTER.x
	# move indicator while button is held
	if throw_pressed:
		direction = 0
		velocity.x = 0
		indicator_rotation += INDICATOR_ROTATION_SPEED * rotation_direction
		throw_indicator.position = INDICATOR_DISTANCE * Vector2(cos(indicator_rotation), sin(indicator_rotation)) + INDICATOR_ROTATION_CENTER
		throw_indicator.rotation = indicator_rotation
		throw_indicator.visible = true
	else:
		throw_indicator.visible = false
	# throw talisman when button is released
	if Input.is_action_just_released("throw"):
		var v: Vector2 = INDICATOR_DISTANCE * Vector2(cos(indicator_rotation), sin(indicator_rotation)) + INDICATOR_ROTATION_CENTER
		throw_talisman.emit(v.normalized())
	if Input.is_action_just_pressed("drop"):
		var v: Vector2 = Vector2.ZERO
		throw_talisman.emit(v)

	if direction != 0:
		last_direction = direction
	move_and_slide()
	
func update_animation():
	if is_on_floor():
		if velocity == Vector2.ZERO:
			animation_tree["parameters/conditions/idle"] = true
			animation_tree["parameters/conditions/run"] = false
		else:
			animation_tree["parameters/conditions/idle"] = false
			animation_tree["parameters/conditions/run"] = true
	
	if Input.is_action_just_pressed("attack"):
		animation_tree["parameters/conditions/attack"] = true
	else:
		animation_tree["parameters/conditions/attack"] = false
	
	if direction != 0:
		animation_tree["parameters/Attack/blend_position"] = direction
		animation_tree["parameters/Run/blend_position"] = direction
		animation_tree["parameters/Idle/blend_position"] = direction
		animation_tree["parameters/JumpSquad/blend_position"] = direction
		animation_tree["parameters/FallUp/blend_position"] = direction
		animation_tree["parameters/JumpPeak/blend_position"] = direction
		animation_tree["parameters/FallDown/blend_position"] = direction
	
	# jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		animation_tree["parameters/conditions/jump"] = true
	else:
		animation_tree["parameters/conditions/jump"] = false
		
	if not is_on_floor():
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/run"] = false
		if abs(velocity.y) < 20:
			animation_tree["parameters/conditions/jump_peak"] = true
		else:
			animation_tree["parameters/conditions/jump_peak"] = false
			# y = down
			if velocity.y > 0:
				animation_tree["parameters/conditions/fall_up"] = false
				animation_tree["parameters/conditions/fall_down"] = true
			if velocity.y < 0:
				animation_tree["parameters/conditions/fall_up"] = true
				animation_tree["parameters/conditions/fall_down"] = false
	else:
		animation_tree["parameters/conditions/fall_down"] = false
		animation_tree["parameters/conditions/fall_up"] = false
		animation_tree["parameters/conditions/jump_peak"] = false

		
	# Landing
	if is_on_floor() and last_frame_in_air:
		animation_tree["parameters/conditions/fall_down"] = false
		animation_tree["parameters/conditions/fall_up"] = false
		animation_tree["parameters/conditions/jump_peak"] = false
		if velocity.x == 0:
			animation_tree["parameters/conditions/idle"] = true
			animation_tree["parameters/conditions/run"] = false
		else:
			animation_tree["parameters/conditions/run"] = true
			animation_tree["parameters/conditions/idle"] = false
