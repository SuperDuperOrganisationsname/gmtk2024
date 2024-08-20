extends CharacterBody2D

signal toggle_pause_menu
signal throw_talisman(vector: Vector2)
signal player_hit(cur_health: int)
signal player_dead

var death_timer: int = -1
const DEATH_WAIT_TIMER: int = 30

var can_throw: int = 0
var can_move: bool = true
var update_anim: bool = true

const SPEED = 130.0
var JUMP_VELOCITY = -300.0
const INDICATOR_DISTANCE = 18
const INDICATOR_ROTATION_SPEED = 0.2
const INDICATOR_ROTATION_CENTER = Vector2(0, -17)

var direction = 1
var last_direction = 1
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity_multiplier: float = 1.0
var indicator_rotation = 0

# checks if the last frame was in the air, to detect when you land
var last_frame_in_air = false

var last_y_velo = 0

@export_group("Health")
@export var max_health: int = 3
@export var cur_health: int = 3

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
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var land_sound: AudioStreamPlayer2D = $LandSound

func _ready() -> void:
	animation_tree.active = true
	throw_indicator.visible = false
	player_hit.emit(cur_health)	
	
func _process(_delta: float) -> void:
	if update_anim:
		update_animation()
	last_frame_in_air = not is_on_floor()
	last_y_velo = velocity.y	
	if can_throw > 0 and can_throw < 3:
		can_throw -= 1
	if death_timer > 0:
		death_timer -= 1
	
	if death_timer == 20:
		_on_game_player_reset_health()
	elif death_timer == 0:
		player_dead.emit()
		death_timer = -1
		

func _physics_process(delta):
	if animation_tree["parameters/conditions/death"]:
		can_move = false
		update_anim = false
	var throw_pressed = Input.is_action_pressed("throw", true) and can_throw == 0
	# Add the gravity.
	if not is_on_floor():
		if Input.is_action_pressed("down"):
			gravity_multiplier = 2.0
			scale.x = 0.8
			scale.y = 1.2
		else:
			gravity_multiplier = 1.0
			scale = Vector2(1, 1)
		velocity.y += gravity * delta * gravity_multiplier
	else:
		scale = Vector2(1, 1)
		coyote_timer.start(coyote_time)	
		velocity.y = 0	
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and can_move:
		input_buffer.start(jump_buffer_time)
	if input_buffer.time_left > 0 and coyote_timer.time_left > 0:
		jump_sound.play()	
		coyote_timer.stop()
		velocity.y = JUMP_VELOCITY
		
	direction = Input.get_axis("move_left", "move_right")
	var rotation_direction = direction
	# left -1, right +1
	if direction and not throw_pressed and can_move:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Throw indicator
	# Setup throw indicator
	if Input.is_action_just_pressed("throw", true) and can_throw == 0:
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
	if Input.is_action_just_released("throw", true) and can_throw == 0:
		var v: Vector2 = INDICATOR_DISTANCE * Vector2(cos(indicator_rotation), sin(indicator_rotation))
		throw_talisman.emit(v.normalized())
		can_throw = 3
	if Input.is_action_just_released("drop", true) and can_throw == 0:
		var v: Vector2 = Vector2(0, 0.001)
		throw_talisman.emit(v)
		can_throw = 3

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
		animation_tree["parameters/Death/blend_position"] = direction
	
	# jumping
	if Input.is_action_just_pressed("jump") and is_on_floor() and can_move:
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
		if last_y_velo > 200:
			land_sound.play()
		animation_tree["parameters/conditions/fall_down"] = false
		animation_tree["parameters/conditions/fall_up"] = false
		animation_tree["parameters/conditions/jump_peak"] = false
		if velocity.x == 0:
			animation_tree["parameters/conditions/idle"] = true
			animation_tree["parameters/conditions/run"] = false
		else:
			animation_tree["parameters/conditions/run"] = true
			animation_tree["parameters/conditions/idle"] = false


func _on_return_talisman() -> void:
	can_throw = 2


func _enable_player_movement(enable: bool) -> void:
	can_move = enable

func on_enemy_hit(body: Node2D) -> void:
	cur_health -= 1
	if cur_health <= 0:
		cur_health = 0
		if death_timer == -1:
			# reset player animations and play death animation	
			animation_tree["parameters/conditions/attack"] = false 
			animation_tree["parameters/conditions/run"] = false 
			animation_tree["parameters/conditions/idle"] = false 
			animation_tree["parameters/conditions/jump"] = false 
			animation_tree["parameters/conditions/fall_up"] = false 
			animation_tree["parameters/conditions/jump_peak"] = false 
			animation_tree["parameters/conditions/fall_down"] = false 
			animation_tree["parameters/conditions/death"] = true 
			
			death_timer = DEATH_WAIT_TIMER
	player_hit.emit(cur_health)	

func kill_player():
	if death_timer == -1:
		# reset player animations and play death animation	
		animation_tree["parameters/conditions/attack"] = false 
		animation_tree["parameters/conditions/run"] = false 
		animation_tree["parameters/conditions/idle"] = false 
		animation_tree["parameters/conditions/jump"] = false 
		animation_tree["parameters/conditions/fall_up"] = false 
		animation_tree["parameters/conditions/jump_peak"] = false 
		animation_tree["parameters/conditions/fall_down"] = false 
		animation_tree["parameters/conditions/death"] = true 
		
		death_timer = DEATH_WAIT_TIMER

func _on_game_player_reset_health() -> void:
	cur_health = max_health
	animation_tree["parameters/conditions/death"] = false 
	update_anim = true	
	can_move = true
	player_hit.emit(cur_health)


func congratulations():
	JUMP_VELOCITY = -500
