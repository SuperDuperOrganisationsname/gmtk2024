extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if animation_player.current_animation != "attack":
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("move_left", "move_right")
		# left -1, right +1
		if direction:
			velocity.x = direction * SPEED
			animation_player.play("run")
			if direction < 0:
				animated_sprite.flip_h = true
			else:
				animated_sprite.flip_h = false
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			animation_player.play("idle")
		
	if Input.is_action_just_pressed("attack"):
		velocity.x = 0
		animation_player.play("attack")

	move_and_slide()
